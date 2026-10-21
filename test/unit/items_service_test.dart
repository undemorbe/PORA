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
  }) => _call();

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
}
