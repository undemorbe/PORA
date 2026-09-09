import 'package:pora/core/features/item_detail/data/datasource/items_remote.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/cache/offline_policy.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_kinds.dart';

String _itemCacheKey(String itemId) => 'items:item:$itemId:v1';

/// Оборачивает `ItemsRemote` в `Either<Failure, T>`.
/// Идемпотентные write-операции (отметка куплено / удаление / правка / пинг)
/// при отсутствии сети уходят в [Outbox] и возвращают [QueuedSuccess];
/// кэш патчится оптимистично, чтобы UI сразу отразил изменение.
class ItemsService implements ItemsRepository {
  final ItemsRemote remote;
  final Outbox outbox;
  const ItemsService({required this.remote, required this.outbox});

  @override
  Future<Either<Failure, ProductEntity>> getItem({
    required String itemId,
  }) async {
    try {
      final model = await remote.getItem(itemId: itemId);
      await HiveJsonCache.put(_itemCacheKey(itemId), model.toJson());
      return Right(model);
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      // Кэш товара отдаём только при проблемах с доступностью, не при 4xx.
      if (canServeCache(failure)) {
        final cached = await HiveJsonCache.read(_itemCacheKey(itemId));
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
    try {
      final body = _body(
        name: name,
        section: section,
        quantity: quantity,
        unit: unit,
        priority: priority,
        urgent: urgent,
        remindEveryDays: remindEveryDays,
      );
      await remote.updateItem(itemId: itemId, body: body);
      await _patchCachedItem(itemId, body);
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        final body = _body(
          name: name,
          section: section,
          quantity: quantity,
          unit: unit,
          priority: priority,
          urgent: urgent,
          remindEveryDays: remindEveryDays,
        );
        await _patchCachedItem(itemId, body);
        await outbox.enqueue(OutboxKinds.itemUpdate, {
          'item-id': itemId,
          'body': body,
        });
        return Right(const QueuedSuccess());
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Success>> deleteItem({required String itemId}) async {
    try {
      await remote.deleteItem(itemId: itemId);
      await HiveJsonCache.invalidate(_itemCacheKey(itemId));
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        await HiveJsonCache.invalidate(_itemCacheKey(itemId));
        await outbox.enqueue(OutboxKinds.itemDelete, {'item-id': itemId});
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
        await outbox.enqueue(OutboxKinds.itemNotify, {
          'item-id': itemId,
          'to': to,
          'message': message,
        });
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
      await _patchCachedItem(itemId, {'checked': checked});
      return Right(const ServerSuccess());
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure.isConnectivity) {
        await _patchCachedItem(itemId, {'checked': checked});
        await outbox.enqueue(OutboxKinds.itemMarkBought, {
          'item-id': itemId,
          'checked': checked,
        });
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

  Future<void> _patchCachedItem(
    String itemId,
    Map<String, dynamic> patch,
  ) async {
    final raw = await HiveJsonCache.read(_itemCacheKey(itemId));
    if (raw is! Map) return;
    final updated = Map<String, dynamic>.from(raw)..addAll(patch);
    await HiveJsonCache.put(_itemCacheKey(itemId), updated);
  }
}
