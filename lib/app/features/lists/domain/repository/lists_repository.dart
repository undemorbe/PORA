import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class ListsRepository {
  Future<Either<Failure, ListsArrayEntity>> getFamilyLists({
    required String fid,
  });
  Future<Either<Failure, Success>> createList({
    required String name,
    String? fid,
  });
  Future<Either<Failure, ListEntity>> getList({required String lid});
  Future<Either<Failure, Success>> addItemToList({
    required String lid,
    required ProductEntity product,
  });
  Future<Either<Failure, Success>> deleteList({required String lid});

  /// PUT /items/{iid} — backend требует **все** поля в теле.
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
}
