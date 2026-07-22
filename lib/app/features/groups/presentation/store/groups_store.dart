import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/families/domain/usecase/create_family.dart';
import 'package:pora/app/features/families/domain/usecase/get_families.dart';
import 'package:pora/app/features/groups/domain/entity/group.dart';
import 'package:pora/app/features/lists/domain/usecase/create_list.dart';
import 'package:pora/app/features/lists/domain/usecase/delete_list.dart';
import 'package:pora/app/features/lists/domain/usecase/get_families_lists.dart';
import 'package:pora/app/features/user/domain/usecase/user/get_user.dart';
import 'package:pora/app/internal/logging/logger.dart';
part 'groups_store.g.dart';

class GroupsStore = _GroupsStoreBase with _$GroupsStore;

abstract class _GroupsStoreBase with Store {
  @observable
  ObservableList<GroupEntity> groups = ObservableList<GroupEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    final aggregated = <GroupEntity>[];

    // 1. Все families + их lists.
    try {
      final famResp = await GetIt.I<GetFamiliesUseCase>().call();
      if (famResp.isRight) {
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
        for (final list in userResp.right.selfLists ?? const []) {
          aggregated.add(GroupEntity(list: list));
        }
      }
    } catch (e, s) {
      Logger.talker.error('groups: user fetch failed', e, s);
    }

    groups = ObservableList<GroupEntity>.of(aggregated);
    isLoading = false;
  }

  /// Создать группу. Личная → просто createList(fid: null).
  /// Общая → createFamily(name) → createList(name, fid). Backend возможно
  /// создаёт default list сам — в этом случае getFamilies() уже подтянет.
  @action
  Future<bool> createGroup({required String name, required bool shared}) async {
    isLoading = true;
    try {
      if (shared) {
        // 1. createFamily → возвращает fid.
        final famRes = await GetIt.I<CreateFamilyUseCase>().call(name: name);
        if (famRes.isLeft) {
          isLoading = false;
          errorMessage = famRes.left.message;
          return false;
        }
        final fid = famRes.right;
        // 2. createList(name, fid) — создаём default list с тем же именем.
        final listRes = await GetIt.I<CreateListUseCase>().call(
          name: name,
          fid: fid,
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
    if (res.isRight) {
      groups.removeWhere((x) => x.list.id == g.list.id);
    } else {
      errorMessage = res.left.message;
    }
  }
}
