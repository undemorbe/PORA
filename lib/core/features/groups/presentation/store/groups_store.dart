import 'dart:async';
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/platform/home_widget_service.dart';
import 'package:pora/core/features/families/data/models/member_model.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/features/families/domain/usecase/create_family.dart';
import 'package:pora/core/features/families/domain/usecase/delete_family.dart';
import 'package:pora/core/features/families/domain/usecase/leave_family.dart';
import 'package:pora/core/features/groups/domain/entity/group.dart';
import 'package:pora/core/features/groups/domain/usecase/get_user_groups.dart';
import 'package:pora/core/features/lists/data/models/lists/list_model.dart';
import 'package:pora/core/features/lists/domain/usecase/create_list.dart';
import 'package:pora/core/features/lists/domain/usecase/delete_list.dart';
import 'package:pora/core/features/lists/domain/usecase/get_families_lists.dart';
import 'package:pora/core/features/user/domain/usecase/user/get_user.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/network/single_flight.dart';
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

  /// id текущего пользователя — для [GroupEntity.canDelete] / `canLeave`.
  @observable
  String? currentUserId;

  /// load() дёргают DI (`..load()`), groups_screen, WS, pull-to-refresh и
  /// recipe-флоу — параллельные вызовы склеиваем в один проход.
  final _loadFlight = SingleFlight<void>();

  Future<void> load() => _loadFlight.run(_load);

  @action
  Future<void> _load() async {
    isLoading = true;
    errorMessage = null;

    // Render the last known state immediately, then refresh it from network.
    final cachedAtStart = await _readSnapshot();
    if (cachedAtStart.isNotEmpty) {
      groups = ObservableList<GroupEntity>.of(cachedAtStart);
      usingCache = true;
    }

    // Один GET /user/groups: семьи + их lists + личные lists.
    final userIdFuture = _fetchUserId();
    final fresh = await _fetchGroups();
    currentUserId = await userIdFuture ?? currentUserId;

    if (fresh != null) {
      // Свежие данные — сохраняем snapshot, снимаем cache-флаг.
      groups = ObservableList<GroupEntity>.of(fresh);
      usingCache = false;
      await _writeSnapshot(fresh);
      _updateHomeWidget(fresh);
    } else if (cachedAtStart.isNotEmpty) {
      // Сеть не ответила — остаёмся на snapshot'е, уже показанном выше.
      usingCache = true;
    } else {
      groups = ObservableList<GroupEntity>();
      errorMessage = 'No internet & no cached data';
    }
    isLoading = false;
  }

  /// Все группы пользователя. `null` — `/user/groups` не ответил.
  Future<List<GroupEntity>?> _fetchGroups() async {
    try {
      final res = await GetIt.I<GetUserGroupsUseCase>().call();
      return res.fold<List<GroupEntity>?>((failure) {
        Logger.talker.warning('groups: fetch failed: ${failure.message}');
        return null;
      }, (data) => data.groups);
    } catch (e, s) {
      Logger.talker.error('groups: fetch failed', e, s);
      return null;
    }
  }

  /// `/user/me` single-flight'ится и офлайн отдаётся из кэша профиля.
  Future<String?> _fetchUserId() async {
    try {
      final res = await GetIt.I<GetUserUseCase>().call();
      return res.fold<String?>((failure) {
        Logger.talker.warning('groups: user fetch failed: ${failure.message}');
        return null;
      }, (user) => user.id);
    } catch (e, s) {
      Logger.talker.error('groups: user fetch failed', e, s);
      return null;
    }
  }

  /// Точечный refresh одной семьи по WS-событию: один `/families/{fid}/lists`
  /// вместо полного `/families` + N×lists + `/user/me`. Незнакомая семья
  /// (вступили / создали) → полный [load].
  @action
  Future<void> refreshFamily(String fid) async {
    if (_loadFlight.isRunning) return load();
    final known = groups.where((g) => g.familyId == fid).firstOrNull;
    if (known == null) return load();

    final res = await GetIt.I<GetFamiliesListsUseCase>().call(fid: fid);
    if (res.isLeft) return;
    final fresh = [
      for (final list in res.right.lists)
        GroupEntity(
          list: list,
          members: known.members,
          ownerId: known.ownerId,
          familyId: fid,
        ),
    ];
    // Заменяем группы семьи на месте, сохраняя порядок остальных.
    final next = <GroupEntity>[];
    var inserted = false;
    for (final g in groups) {
      if (g.familyId != fid) {
        next.add(g);
      } else if (!inserted) {
        next.addAll(fresh);
        inserted = true;
      }
    }
    groups = ObservableList<GroupEntity>.of(next);
    await _writeSnapshot(next);
    _updateHomeWidget(next);
  }

  void _updateHomeWidget(List<GroupEntity> data) {
    // Android home-screen widget: краткая сводка по спискам.
    unawaited(
      HomeWidgetService.instance.update(
        count: data.length,
        items: data.map((g) => g.list.name).toList(),
      ),
    );
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
          .map(
            (m) =>
                MemberModel(
                      id: (m['id'] as String?) ?? '',
                      name: (m['name'] as String?) ?? '',
                      surname: m['surname'] as String?,
                      imageUrl: m['image-url'] as String?,
                      joinedAt: (m['joined-at'] as String?) ?? '',
                      colorCode: (m['color'] as String?) ?? '',
                    )
                    as MemberEntity,
          )
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

  /// Удалить группу. `null` — успех, иначе [Failure] для UI.
  /// Личная → DELETE /lists. Общая → только DELETE /families (каскадом
  /// уходят все её списки): при 403 список не трогаем, иначе не-владелец
  /// удалил бы его у всей семьи.
  @action
  Future<Failure?> deleteGroup(GroupEntity g) async {
    final fid = g.familyId;
    if (fid == null) {
      final res = await GetIt.I<DeleteListUseCase>().call(lid: g.list.id);
      if (res.isLeft) {
        Logger.talker.warning('deleteList failed: ${res.left.message}');
        return res.left;
      }
      await _dropGroups((x) => x.list.id == g.list.id);
      return null;
    }

    final res = await GetIt.I<DeleteFamilyUseCase>().call(familyId: fid);
    if (res.isLeft) {
      Logger.talker.warning('deleteFamily failed: ${res.left.message}');
      return res.left;
    }
    await _dropGroups((x) => x.familyId == fid);
    return null;
  }

  /// Выйти из общей группы (семьи). Списки остаются у остальных участников.
  @action
  Future<Failure?> leaveGroup(GroupEntity g) async {
    final fid = g.familyId;
    if (fid == null) return null;
    final res = await GetIt.I<LeaveFamilyUseCase>().call(familyId: fid);
    if (res.isLeft) {
      Logger.talker.warning('leaveFamily failed: ${res.left.message}');
      return res.left;
    }
    await _dropGroups((x) => x.familyId == fid);
    return null;
  }

  Future<void> _dropGroups(bool Function(GroupEntity) test) async {
    groups.removeWhere(test);
    final next = groups.toList();
    await _writeSnapshot(next);
    _updateHomeWidget(next);
  }
}
