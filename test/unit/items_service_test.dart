import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/features/item_detail/data/datasource/items_remote.dart';
import 'package:pora/core/features/item_detail/data/models/add_item_response.dart';
import 'package:pora/core/features/item_detail/data/service/items_service.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/cache/list_cache_patcher.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_kinds.dart';

class _FakeRemote implements ItemsRemote {
  Object? error;
  Map<String, dynamic>? lastUpdateBody;

  Future<void> _call() async {
    final e = error;
    if (e != null) throw e;
  }

  @override
  Future<ProductModel> getItem({required String itemId}) =>
      throw UnimplementedError();

  @override
  Future<AddItemResponse> addItem({
    required String listId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<void> updateItem({
    required String itemId,
    required Map<String, dynamic> body,
  }) {
    lastUpdateBody = body;
    return _call();
  }

  @override
  Future<void> deleteItem({required String itemId}) => _call();

  @override
  Future<void> notify({
    required String itemId,
    required Map<String, dynamic> body,
  }) => _call();

  @override
  Future<void> markBought({required String itemId, required bool checked}) =>
      _call();
}

/// Патчер, у которого «сломан диск» — проверяем, что сбой кэша не
/// теряет офлайн-запись и не превращает серверный успех в `Left`.
class _ThrowingPatcher extends ListCachePatcher {
  const _ThrowingPatcher();

  @override
  Future<void> patchItem(String itemId, Map<String, dynamic> patch) async =>
      throw StateError('disk');

  @override
  Future<void> removeItem(String itemId) async => throw StateError('disk');
}

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: DioExceptionType.connectionError,
);

DioException _http(int status) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
  ),
);

Future<Map<String, dynamic>?> _cachedListItem(String id) async {
  final raw = await HiveJsonCache.read(CacheKeys.listContent('l1')) as Map;
  for (final s in raw['sections'] as List) {
    for (final it in s['items'] as List) {
      if (it['id'] == id) return Map<String, dynamic>.from(it as Map);
    }
  }
  return null;
}

void main() {
  late Directory tmp;
  late _FakeRemote remote;
  late Outbox outbox;
  late ItemsService service;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_items_service_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-cache');
    await Hive.deleteBoxFromDisk('pora-outbox');
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    remote = _FakeRemote();
    outbox = Outbox();
    await outbox.clear();
    await HiveJsonCache.clear();
    await HiveJsonCache.put(CacheKeys.listContent('l1'), {
      'id': 'l1',
      'name': 'L',
      'sections': [
        {
          'name': 's',
          'items': [
            {'id': 'i1', 'name': 'milk', 'checked': false},
          ],
        },
      ],
    });
    service = ItemsService(
      remote: remote,
      outbox: outbox,
      listCache: const ListCachePatcher(),
    );
  });

  tearDown(() => outbox.dispose());

  test('online markBought patches list cache, nothing queued', () async {
    final res = await service.markBought(itemId: 'i1', checked: true);

    expect(res.right, isA<ServerSuccess>());
    expect((await _cachedListItem('i1'))!['checked'], isTrue);
    expect(await outbox.length, 0);
  });

  test(
    'offline toggle twice → one coalesced entry, cache has last value',
    () async {
      remote.error = _offline();

      final a = await service.markBought(itemId: 'i1', checked: true);
      final b = await service.markBought(itemId: 'i1', checked: false);

      expect(a.right, isA<QueuedSuccess>());
      expect(b.right, isA<QueuedSuccess>());
      expect((await _cachedListItem('i1'))!['checked'], isFalse);
      final all = await outbox.all();
      expect(all.single.args['checked'], isFalse);
    },
  );

  test(
    'offline update then delete → only delete queued, item gone from cache',
    () async {
      remote.error = _offline();

      await service.updateItem(
        itemId: 'i1',
        name: 'oat milk',
        section: 's',
        quantity: 1,
        unit: '',
        priority: 0,
        urgent: false,
        checked: true,
        remindEveryDays: null,
      );
      await service.deleteItem(itemId: 'i1');

      expect((await outbox.all()).map((e) => e.kind), [OutboxKinds.itemDelete]);
      expect(await _cachedListItem('i1'), isNull);
      expect(await HiveJsonCache.read(CacheKeys.item('i1')), isNull);
    },
  );

  test('5xx is queued like offline', () async {
    remote.error = _http(503);

    final res = await service.markBought(itemId: 'i1', checked: true);

    expect(res.right, isA<QueuedSuccess>());
    expect(await outbox.length, 1);
  });

  test('4xx returns Left, nothing queued, cache untouched', () async {
    remote.error = _http(403);

    final res = await service.markBought(itemId: 'i1', checked: true);

    expect(res.isLeft, isTrue);
    expect(await outbox.length, 0);
    expect((await _cachedListItem('i1'))!['checked'], isFalse);
  });

  test('concurrent offline writes keep both patches in item cache', () async {
    remote.error = _offline();
    await HiveJsonCache.put(CacheKeys.item('i1'), {
      'id': 'i1',
      'name': 'milk',
      'checked': false,
    });

    await Future.wait([
      service.updateItem(
        itemId: 'i1',
        name: 'oat milk',
        section: 's',
        quantity: 1,
        unit: '',
        priority: 0,
        urgent: false,
        checked: true,
        remindEveryDays: null,
      ),
      service.markBought(itemId: 'i1', checked: true),
    ]);

    final cached = await HiveJsonCache.read(CacheKeys.item('i1')) as Map;
    expect(cached['name'], 'oat milk');
    expect(cached['checked'], isTrue);
    final listed = (await _cachedListItem('i1'))!;
    expect(listed['name'], 'oat milk');
    expect(listed['checked'], isTrue);
  });

  test('online updateItem patches list cache', () async {
    final res = await service.updateItem(
      itemId: 'i1',
      name: 'oat milk',
      section: 's',
      quantity: 2,
      unit: 'l',
      priority: 0,
      urgent: false,
      checked: false,
      remindEveryDays: null,
    );

    expect(res.right, isA<ServerSuccess>());
    final listed = (await _cachedListItem('i1'))!;
    expect(listed['name'], 'oat milk');
    expect(listed['quantity'], 2);
    expect(await outbox.length, 0);
  });

  test('online updateItem sends checked and remind-every-days', () async {
    final res = await service.updateItem(
      itemId: 'i1',
      name: 'milk',
      section: 's',
      quantity: 1,
      unit: '',
      priority: 0,
      urgent: true,
      checked: true,
      remindEveryDays: 7,
    );

    expect(res.right, isA<ServerSuccess>());
    expect(remote.lastUpdateBody!['checked'], isTrue);
    expect(remote.lastUpdateBody!['remind-every-days'], 7);
    final listed = (await _cachedListItem('i1'))!;
    expect(listed['checked'], isTrue);
    expect(listed['remind-every-days'], 7);
  });

  test('offline updateItem queues body with checked and reminder', () async {
    remote.error = _offline();

    final res = await service.updateItem(
      itemId: 'i1',
      name: 'milk',
      section: 's',
      quantity: 1,
      unit: '',
      priority: 0,
      urgent: true,
      checked: true,
      remindEveryDays: 3,
    );

    expect(res.right, isA<QueuedSuccess>());
    final entry = (await outbox.all()).single;
    expect(entry.kind, OutboxKinds.itemUpdate);
    final body = Map<String, dynamic>.from(entry.args['body'] as Map);
    expect(body['checked'], isTrue);
    expect(body['remind-every-days'], 3);
    expect(body['urgent'], isTrue);
    expect((await _cachedListItem('i1'))!['checked'], isTrue);
  });

  test('offline markBought then update → only update queued', () async {
    remote.error = _offline();

    await service.markBought(itemId: 'i1', checked: true);
    await service.updateItem(
      itemId: 'i1',
      name: 'milk',
      section: 's',
      quantity: 1,
      unit: '',
      priority: 0,
      urgent: true,
      checked: true,
      remindEveryDays: null,
    );

    final entry = (await outbox.all()).single;
    expect(entry.kind, OutboxKinds.itemUpdate);
    expect((entry.args['body'] as Map)['checked'], isTrue);
  });

  test('online deleteItem removes item from list cache', () async {
    final res = await service.deleteItem(itemId: 'i1');

    expect(res.right, isA<ServerSuccess>());
    expect(await _cachedListItem('i1'), isNull);
    expect(await outbox.length, 0);
  });

  test('offline notify → QueuedSuccess and one item.notify entry', () async {
    remote.error = _offline();

    final res = await service.notify(
      itemId: 'i1',
      to: const ['u1'],
      message: 'buy',
    );

    expect(res.right, isA<QueuedSuccess>());
    final all = await outbox.all();
    expect(all.single.kind, OutboxKinds.itemNotify);
    expect(all.single.args['message'], 'buy');
  });

  group('cache patch failure', () {
    setUp(() {
      service = ItemsService(
        remote: remote,
        outbox: outbox,
        listCache: const _ThrowingPatcher(),
      );
    });

    test('offline markBought is still queued', () async {
      remote.error = _offline();

      final res = await service.markBought(itemId: 'i1', checked: true);

      expect(res.right, isA<QueuedSuccess>());
      expect(await outbox.length, 1);
    });

    test('offline deleteItem is still queued', () async {
      remote.error = _offline();

      final res = await service.deleteItem(itemId: 'i1');

      expect(res.right, isA<QueuedSuccess>());
      expect((await outbox.all()).single.kind, OutboxKinds.itemDelete);
    });

    test('online markBought stays ServerSuccess', () async {
      final res = await service.markBought(itemId: 'i1', checked: true);

      expect(res.right, isA<ServerSuccess>());
      expect(await outbox.length, 0);
    });

    test('online deleteItem stays ServerSuccess', () async {
      final res = await service.deleteItem(itemId: 'i1');

      expect(res.right, isA<ServerSuccess>());
    });
  });
}
