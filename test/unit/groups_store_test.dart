import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:pora/core/features/groups/data/models/user_groups_model.dart';
import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/features/groups/domain/repository/groups_repository.dart';
import 'package:pora/core/features/groups/domain/usecase/get_user_groups.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/internal/errors/failure.dart';
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
}
