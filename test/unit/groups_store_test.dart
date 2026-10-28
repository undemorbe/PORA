import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:pora/core/features/families/domain/repository/family_repository.dart';
import 'package:pora/core/features/families/domain/usecase/delete_family.dart';
import 'package:pora/core/features/families/domain/usecase/leave_family.dart';
import 'package:pora/core/features/groups/domain/entity/group.dart';
import 'package:pora/core/features/groups/data/models/user_groups_model.dart';
import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/features/groups/domain/repository/groups_repository.dart';
import 'package:pora/core/features/groups/domain/usecase/get_user_groups.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/core/features/lists/domain/usecase/delete_list.dart';
import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/features/user/domain/usecase/user/get_user.dart';
import 'package:pora/core/internal/errors/api_error_code.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Ответ `GET /user/groups` в формате Go-бэкенда (embedded FamilyInfo + lists).
const _payload = <String, dynamic>{
  'families': [
    {
      'id': 'fam-1',
      'name': 'Home',
      'owner': {
        'id': 'u-1',
        'name': 'Ann',
        'surname': 'A',
        'image-url': 'http://x/a.png',
        'joined-at': '2026-01-01T00:00:00Z',
        'color': 'red',
      },
      'members': [
        {
          'id': 'u-2',
          'name': 'Bob',
          'surname': '',
          'joined-at': '2026-01-02T00:00:00Z',
          'color': 'blue',
        },
      ],
      'created-at': '2026-01-01T00:00:00Z',
      'lists': [
        {
          'id': 'l-1',
          'name': 'Groceries',
          'sections': [
            {
              'name': 'Dairy',
              'items': [
                {'id': 'i-1', 'name': 'Milk', 'priority': 1, 'urgent': false},
              ],
            },
          ],
          'created-at': '2026-01-01T00:00:00Z',
          'updated-at': '2026-01-01T00:00:00Z',
        },
        {'id': 'l-2', 'name': 'Party', 'sections': []},
      ],
    },
    {
      // Семья без списков и без участников кроме owner'а (members: null).
      'id': 'fam-2',
      'name': 'Empty',
      'owner': {
        'id': 'u-1',
        'name': 'Ann',
        'joined-at': '2026-01-01T00:00:00Z',
        'color': 'red',
      },
      'members': null,
      'created-at': '2026-01-01T00:00:00Z',
      'lists': [],
    },
  ],
  'personal-lists': [
    {'id': 'l-3', 'name': 'Mine', 'sections': []},
  ],
};

class _FakeGroupsRepository implements GroupsRepository {
  Either<Failure, UserGroupsEntity> result;
  int calls = 0;

  _FakeGroupsRepository(this.result);

  @override
  Future<Either<Failure, UserGroupsEntity>> getUserGroups() async {
    calls++;
    return result;
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this.id);
  final String id;

  @override
  Future<Either<Failure, UserEntity>> getUser() async =>
      Right(UserEntity(id: id));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFamilyRepository implements FamilyRepository {
  Either<Failure, Success> deleteResult = Right(const ServerSuccess());
  Either<Failure, Success> leaveResult = Right(const ServerSuccess());
  final deleted = <String>[];
  final left = <String>[];

  @override
  Future<Either<Failure, Success>> deleteFamily({
    required String familyId,
  }) async {
    deleted.add(familyId);
    return deleteResult;
  }

  @override
  Future<Either<Failure, Success>> leaveFamily({
    required String familyId,
  }) async {
    left.add(familyId);
    return leaveResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeListsRepository implements ListsRepository {
  final deleted = <String>[];

  @override
  Future<Either<Failure, Success>> deleteList({required String lid}) async {
    deleted.add(lid);
    return Right(const ServerSuccess());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _forbidden = ApiFailure(
  code: ApiErrorCode.forbidden,
  message: 'forbidden',
  statusCode: 403,
);

void main() {
  late Directory tmp;
  late _FakeGroupsRepository repo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('groups_store_test');
    Hive.init(tmp.path);
    repo = _FakeGroupsRepository(Right(UserGroupsModel.fromJson(_payload)));
    GetIt.I.registerFactory<GetUserGroupsUseCase>(
      () => GetUserGroupsUseCase(groupsRepository: repo),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
    await Hive.deleteFromDisk();
    await Hive.close();
    await tmp.delete(recursive: true);
  });

  test('UserGroupsModel flattens families lists then personal lists', () {
    final groups = UserGroupsModel.fromJson(_payload).groups;

    expect(groups.map((g) => g.list.id), ['l-1', 'l-2', 'l-3']);
    final shared = groups.first;
    expect(shared.familyId, 'fam-1');
    expect(shared.ownerId, 'u-1');
    expect(shared.members.map((m) => m.id), ['u-1', 'u-2']);
    expect(shared.list.sections.single.items.single.name, 'Milk');
    expect(groups.last.isPersonal, isTrue);
    expect(groups.last.members, isEmpty);
  });

  test('full load makes one request and survives cache round-trip', () async {
    final store = GroupsStore();
    await Future.wait([store.load(), store.load()]);

    expect(repo.calls, 1);
    expect(store.usingCache, isFalse);
    expect(store.groups.map((g) => g.list.id), ['l-1', 'l-2', 'l-3']);

    // Сеть отвалилась — новый store поднимается из snapshot'а.
    repo.result = Left(const NetworkFailure());
    final offline = GroupsStore();
    await offline.load();

    expect(offline.usingCache, isTrue);
    expect(offline.errorMessage, isNull);
    expect(offline.groups.map((g) => g.list.id), ['l-1', 'l-2', 'l-3']);
    final cached = offline.groups.first;
    expect(cached.familyId, 'fam-1');
    expect(cached.ownerId, 'u-1');
    expect(cached.members.map((m) => m.id), ['u-1', 'u-2']);
    expect(cached.members.first.colorCode, 'red');
    expect(offline.groups.last.familyId, isNull);
  });

  test(
    'GroupEntity: owner deletes shared, member leaves, personal deletes',
    () {
      final groups = UserGroupsModel.fromJson(_payload).groups;
      final shared = groups.first;
      final personal = groups.last;

      expect(shared.canDelete('u-1'), isTrue);
      expect(shared.canLeave('u-1'), isFalse);
      expect(shared.canDelete('u-2'), isFalse);
      expect(shared.canLeave('u-2'), isTrue);
      // id ещё не известен — общую ни удалить, ни покинуть.
      expect(shared.canDelete(null), isFalse);
      expect(shared.canLeave(null), isFalse);
      expect(personal.canDelete(null), isTrue);
      expect(personal.canLeave('u-2'), isFalse);
    },
  );

  group('delete / leave', () {
    late _FakeFamilyRepository families;
    late _FakeListsRepository lists;

    setUp(() {
      families = _FakeFamilyRepository();
      lists = _FakeListsRepository();
      GetIt.I
        ..registerFactory<GetUserUseCase>(
          () => GetUserUseCase(_FakeUserRepository('u-2')),
        )
        ..registerFactory<DeleteFamilyUseCase>(
          () => DeleteFamilyUseCase(familyRepository: families),
        )
        ..registerFactory<LeaveFamilyUseCase>(
          () => LeaveFamilyUseCase(familyRepository: families),
        )
        ..registerFactory<DeleteListUseCase>(
          () => DeleteListUseCase(listsRepository: lists),
        );
    });

    Future<GroupsStore> loaded() async {
      final store = GroupsStore();
      await store.load();
      return store;
    }

    GroupEntity byId(GroupsStore s, String id) =>
        s.groups.firstWhere((g) => g.list.id == id);

    test('load resolves current user id', () async {
      final store = await loaded();
      expect(store.currentUserId, 'u-2');
    });

    test('403 on shared delete keeps list and groups intact', () async {
      final store = await loaded();
      families.deleteResult = Left(_forbidden);

      final failure = await store.deleteGroup(byId(store, 'l-1'));

      expect(failure, _forbidden);
      expect(families.deleted, ['fam-1']);
      expect(lists.deleted, isEmpty);
      expect(store.groups.map((g) => g.list.id), ['l-1', 'l-2', 'l-3']);
    });

    test(
      'owner delete removes the family only, drops all its groups',
      () async {
        final store = await loaded();

        final failure = await store.deleteGroup(byId(store, 'l-1'));

        expect(failure, isNull);
        expect(families.deleted, ['fam-1']);
        expect(lists.deleted, isEmpty);
        expect(store.groups.map((g) => g.list.id), ['l-3']);
      },
    );

    test('personal delete removes the list only', () async {
      final store = await loaded();

      final failure = await store.deleteGroup(byId(store, 'l-3'));

      expect(failure, isNull);
      expect(lists.deleted, ['l-3']);
      expect(families.deleted, isEmpty);
      expect(store.groups.map((g) => g.list.id), ['l-1', 'l-2']);
    });

    test('leave drops family groups without deleting anything', () async {
      final store = await loaded();

      final failure = await store.leaveGroup(byId(store, 'l-2'));

      expect(failure, isNull);
      expect(families.left, ['fam-1']);
      expect(families.deleted, isEmpty);
      expect(lists.deleted, isEmpty);
      expect(store.groups.map((g) => g.list.id), ['l-3']);
    });

    test('failed leave keeps groups', () async {
      final store = await loaded();
      families.leaveResult = Left(const NetworkFailure());

      final failure = await store.leaveGroup(byId(store, 'l-1'));

      expect(failure, isA<NetworkFailure>());
      expect(store.groups.map((g) => g.list.id), ['l-1', 'l-2', 'l-3']);
    });
  });
}
