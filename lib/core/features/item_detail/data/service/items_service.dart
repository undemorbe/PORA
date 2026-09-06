import 'package:pora/core/features/item_detail/data/datasource/items_remote.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';

String _itemCacheKey(String itemId) => 'items:item:$itemId:v1';

/// Оборачивает `ItemsRemote` в `Either<Failure, T>`.
class ItemsService implements ItemsRepository {
  final ItemsRemote remote;
  const ItemsService({required this.remote});

  @override
  Future<Either<Failure, ProductEntity>> getItem({
    required String itemId,
  }) async {
    try {
      final model = await remote.getItem(itemId: itemId);
      await HiveJsonCache.put(_itemCacheKey(itemId), model.toJson());
      return Right(model);
    } on Exception catch (e) {
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
      return Left(NetworkFailure(e.toString()));
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
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
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
      await remote.updateItem(
        itemId: itemId,
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
      await _patchCachedItem(
        itemId,
        _body(
          name: name,
          section: section,
          quantity: quantity,
          unit: unit,
          priority: priority,
          urgent: urgent,
          remindEveryDays: remindEveryDays,
        ),
      );
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteItem({required String itemId}) async {
    try {
      await remote.deleteItem(itemId: itemId);
      await HiveJsonCache.invalidate(_itemCacheKey(itemId));
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
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
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
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
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
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
