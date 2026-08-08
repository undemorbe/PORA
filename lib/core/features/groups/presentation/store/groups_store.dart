import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/families/data/models/member_model.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/features/families/domain/usecase/create_family.dart';
import 'package:pora/core/features/families/domain/usecase/delete_family.dart';
import 'package:pora/core/features/families/domain/usecase/get_families.dart';
import 'package:pora/core/features/groups/domain/entity/group.dart';
import 'package:pora/core/features/lists/data/models/lists/list_model.dart';
import 'package:pora/core/features/lists/domain/usecase/create_list.dart';
import 'package:pora/core/features/lists/domain/usecase/delete_list.dart';
import 'package:pora/core/features/lists/domain/usecase/get_families_lists.dart';
import 'package:pora/core/features/user/domain/usecase/user/get_user.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/logging/logger.dart';
part 'groups_store.g.dart';

/// Ключ снапшота групп в HiveJsonCache.
const _kGroupsCacheKey = 'groups-snapshot-v1';

class GroupsStore = _GroupsStoreBase with _$GroupsStore;

abstract class _GroupsStoreBase with Store {
  @observable
  ObservableList<GroupEntity> groups = ObservableList<GroupEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  /// True — данные пришли из кэша (сеть не отвечает). UI показывает баннер.
  @observable
  bool usingCache = false;

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;

    final aggregated = <GroupEntity>[];
    var anyLive = false;

    // 1. Все families + их lists.
    try {
      final famResp = await GetIt.I<GetFamiliesUseCase>().call();
      if (famResp.isRight) {
        anyLive = true;
        for (final family in famResp.right) {
          final members = <MemberEntity>[
            family.owner,
            if (family.members != null)
              ...family.members!.whereType<MemberEntity>(),
          ];
          final listsResp = await GetIt.I<GetFamiliesListsUseCase>().call(
            fid: family.id,
          );
          if (listsResp.isRight) {
            for (final list in listsResp.right.lists) {
              aggregated.add(
                GroupEntity(
                  list: list,
                  members: members,
                  ownerId: family.owner.id,
                  familyId: family.id,
                ),
              );
            }
          }
        }
      }
    } catch (e, s) {
      Logger.talker.error('groups: families fetch failed', e, s);
    }

    // 2. Личные lists из /user/me.
    try {
      final userResp = await GetIt.I<GetUserUseCase>().call();
      if (userResp.isRight) {
        anyLive = true;
        for (final list in userResp.right.selfLists ?? const []) {
          aggregated.add(GroupEntity(list: list));
        }
      }
    } catch (e, s) {
      Logger.talker.error('groups: user fetch failed', e, s);
    }

    if (anyLive) {
      // Свежие данные — сохраняем snapshot, снимаем cache-флаг.
      groups = ObservableList<GroupEntity>.of(aggregated);
      usingCache = false;
      await _writeSnapshot(aggregated);
    } else {
      // Ничего не пришло — пробуем поднять из cache.
      final cached = await _readSnapshot();
      if (cached.isNotEmpty) {
        groups = ObservableList<GroupEntity>.of(cached);
        usingCache = true;
      } else {
        groups = ObservableList<GroupEntity>();
        errorMessage = 'No internet & no cached data';
      }
    }
    isLoading = false;
  }

  Future<void> _writeSnapshot(List<GroupEntity> data) async {
    final json = data.map(_serializeGroup).toList();
    await HiveJsonCache.put(_kGroupsCacheKey, json);
  }

  Future<List<GroupEntity>> _readSnapshot() async {
    final raw = await HiveJsonCache.read(_kGroupsCacheKey);
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_deserializeGroup)
        .toList();
  }

  Map<String, dynamic> _serializeGroup(GroupEntity g) {
    // ListEntity → сериализуем минимум (id/name/пустые sections).
    // Секции не тянем в snapshot: groups-экран их не показывает,
    // а offline-детали конкретного списка требуют сети (guard закрывает).
    return {
      'list': {'id': g.list.id, 'name': g.list.name, 'sections': const []},
      'members': g.members
          .map(
            (m) => {
              'id': m.id,
              'name': m.name,
              'surname': m.surname,
              'image-url': m.imageUrl,
              'joined-at': m.joinedAt,
              'color': m.colorCode,
            },
          )
          .toList(),
      'ownerId': g.ownerId,
      'familyId': g.familyId,
    };
  }

  GroupEntity _deserializeGroup(Map<String, dynamic> j) {
    final listJson = (j['list'] as Map).cast<String, dynamic>();
    return GroupEntity(
      list: ListModel.fromJson(listJson),
      members: (j['members'] as List? ?? const [])
          .whereType<Map>()
          .map((m) => MemberModel(
                id: (m['id'] as String?) ?? '',
                name: (m['name'] as String?) ?? '',
                surname: m['surname'] as String?,
                imageUrl: m['image-url'] as String?,
                joinedAt: (m['joined-at'] as String?) ?? '',
                colorCode: (m['color'] as String?) ?? '',
              ) as MemberEntity)
          .toList(),
      ownerId: j['ownerId'] as String?,
      familyId: j['familyId'] as String?,
    );
  }

  /// Создать группу. Личная → просто createList(fid: null).
  /// Общая → createFamily(name) → createList(name, fid).
  @action
  Future<bool> createGroup({required String name, required bool shared}) async {
    isLoading = true;
    try {
      if (shared) {
        final famRes = await GetIt.I<CreateFamilyUseCase>().call(name: name);
        if (famRes.isLeft) {
          isLoading = false;
          errorMessage = famRes.left.message;
          return false;
        }
        final fid = jsonDecode(famRes.right) as Map<String, dynamic>;
        final listRes = await GetIt.I<CreateListUseCase>().call(
          name: name,
          fid: fid['id'],
        );
        if (listRes.isLeft) {
          isLoading = false;
          errorMessage = listRes.left.message;
          return false;
        }
      } else {
        final res = await GetIt.I<CreateListUseCase>().call(name: name);
        if (res.isLeft) {
          isLoading = false;
          errorMessage = res.left.message;
          return false;
        }
      }
      await load();
      return true;
    } catch (e, s) {
      Logger.talker.error('createGroup failed', e, s);
      isLoading = false;
      errorMessage = e.toString();
      return false;
    }
  }

  @action
  Future<void> deleteGroup(GroupEntity g) async {
    final res = await GetIt.I<DeleteListUseCase>().call(lid: g.list.id);
    await GetIt.I<DeleteFamilyUseCase>().call(familyId: g.familyId ?? '');
    if (res.isRight) {
      groups.removeWhere((x) => x.list.id == g.list.id);
      await _writeSnapshot(groups.toList());
    } else {
      errorMessage = res.left.message;
    }
    if (res.isLeft) {
      Logger.talker.error('deleteFamily failed', res.left.message);
    }
  }
}
