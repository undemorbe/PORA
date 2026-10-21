import 'package:pora/core/features/item_detail/data/datasource/items_remote.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/cache/list_cache_patcher.dart';
import 'package:pora/core/internal/cache/offline_policy.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_kinds.dart';

/// Оборачивает `ItemsRemote` в `Either<Failure, T>`.
/// Идемпотентные write-операции (отметка куплено / удаление / правка / пинг)
/// при проблемах со связью уходят в [Outbox] (со схлопыванием по товару) и
/// возвращают [QueuedSuccess]. Кэш товара и все закэшированные списки
/// патчатся и при успехе, и при постановке в очередь — офлайн-UI сразу
/// видит изменение, в том числе после переоткрытия списка.
class ItemsService implements ItemsRepository {
  final ItemsRemote remote;
  final Outbox outbox;
  final ListCachePatcher listCache;
  const ItemsService({
    required this.remote,
    required this.outbox,
    required this.listCache,
  });

  @override
  Future<Either<Failure, ProductEntity>> getItem({
    required String itemId,
  }) async {
    try {
      final model = await remote.getItem(itemId: itemId);
      await HiveJsonCache.put(CacheKeys.item(itemId), model.toJson());
      return Right(model);
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      // Кэш товара отдаём только при проблемах с доступностью, не при 4xx.
      if (canServeCache(failure)) {
        final cached = await HiveJsonCache.read(CacheKeys.item(itemId));
        if (cached is Map) {
          try {
            return Right(
              ProductModel.fromJson(Map<String, dynamic>.from(cached)),
            );
          } catch (_) {
            // Broken cache is treated as a cache miss.
          }
        }
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, String>> addItem({
    required String listId,
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  }) async {
    try {
      final res = await remote.addItem(
        listId: listId,
        body: _body(
          name: name,
          section: section,
          quantity: quantity,
          unit: unit,
          priority: priority,
          urgent: urgent,
          remindEveryDays: remindEveryDays,
        ),
      );
      return Right(res.id);
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, Success>> updateItem({
    required String itemId,
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  }) async {
    final body = _body(
      name: name,
      section: section,
      quantity: quantity,
      unit: unit,
      priority: priority,
      urgent: urgent,
      remindEveryDays: remindEveryDays,
    );
    try {
      await remote.updateItem(itemId: itemId, body: body);
      await _patchEverywhere(itemId, body);
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        await _patchEverywhere(itemId, body);
        await outbox.enqueueCoalesced(OutboxKinds.itemUpdate, {
          'item-id': itemId,
          'body': body,
        }, itemId: itemId);
        return Right(const QueuedSuccess());
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Success>> deleteItem({required String itemId}) async {
    try {
      await remote.deleteItem(itemId: itemId);
      await _removeEverywhere(itemId);
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        await _removeEverywhere(itemId);
        await outbox.enqueueCoalesced(OutboxKinds.itemDelete, {
          'item-id': itemId,
        }, itemId: itemId);
        return Right(const QueuedSuccess());
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Success>> notify({
    required String itemId,
    required List<String>? to,
    required String message,
  }) async {
    try {
      await remote.notify(itemId: itemId, body: {'to': to, 'message': message});
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        await outbox.enqueueCoalesced(OutboxKinds.itemNotify, {
          'item-id': itemId,
          'to': to,
          'message': message,
        }, itemId: itemId);
        return Right(const QueuedSuccess());
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Success>> markBought({
    required String itemId,
    required bool checked,
  }) async {
    try {
      await remote.markBought(itemId: itemId, checked: checked);
      await _patchEverywhere(itemId, {'checked': checked});
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        await _patchEverywhere(itemId, {'checked': checked});
        await outbox.enqueueCoalesced(OutboxKinds.itemMarkBought, {
          'item-id': itemId,
          'checked': checked,
        }, itemId: itemId);
        return Right(const QueuedSuccess());
      }
      return Left(failure);
    }
  }

  Map<String, dynamic> _body({
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  }) => {
    'name': name,
    'section': section,
    'quantity': quantity,
    'unit': unit,
    'priority': priority,
    'urgent': urgent,
    'remind-every-days': remindEveryDays,
  };

  /// Правки кэша товара идут строго по очереди: read→edit→write с await
  /// между шагами, параллельные вызовы (два быстрых офлайн-тапа) иначе
  /// затирают друг друга.
  static Future<void> _tail = Future.value();

  static Future<void> _serialized(Future<void> Function() body) {
    final next = _tail.then((_) => body());
    // Ошибка одной правки не должна рвать очередь для следующих.
    _tail = next.catchError((Object _) {});
    return next;
  }

  /// Патчит кэш карточки товара и все снапшоты списков, где он есть.
  Future<void> _patchEverywhere(String itemId, Map<String, dynamic> patch) =>
      _serialized(() async {
        final raw = await HiveJsonCache.read(CacheKeys.item(itemId));
        if (raw is Map) {
          final updated = Map<String, dynamic>.from(raw)..addAll(patch);
          await HiveJsonCache.put(CacheKeys.item(itemId), updated);
        }
        await listCache.patchItem(itemId, patch);
      });

  Future<void> _removeEverywhere(String itemId) => _serialized(() async {
    await HiveJsonCache.invalidate(CacheKeys.item(itemId));
    await listCache.removeItem(itemId);
  });
}
