import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class ItemsRepository {
  /// GET /items/{iid}
  Future<Either<Failure, ProductEntity>> getItem({required String itemId});

  /// POST /lists/{lid}/items → возвращает id нового товара.
  Future<Either<Failure, String>> addItem({
    required String listId,
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  });

  /// PUT /items/{iid} — все поля обязательны.
  Future<Either<Failure, Success>> updateItem({
    required String itemId,
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  });

  /// DELETE /items/{iid}
  Future<Either<Failure, Success>> deleteItem({required String itemId});

  /// POST /items/{iid}/notify
  /// `to == null` → всем; иначе — список user id.
  /// `message` пустая → бэкенд возьмёт default («Срочно купи …»).
  Future<Either<Failure, Success>> notify({
    required String itemId,
    required List<String>? to,
    required String message,
  });

  /// PATCH /items/{iid}/bought
  Future<Either<Failure, Success>> markBought({
    required String itemId,
    required bool checked,
  });
}
