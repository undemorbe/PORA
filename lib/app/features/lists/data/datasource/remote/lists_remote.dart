import 'package:pora/app/features/lists/data/models/products/product_model.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/internal/di/export.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class ListsRemote {
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
}

class ListsRemoteImpl implements ListsRemote {
  final ApiClient apiClient;

  const ListsRemoteImpl({required this.apiClient});

  @override
  Future<Either<Failure, Success>> addItemToList({
    required String lid,
    required ProductEntity product,
  }) async {
    try {
      final prod = product is ProductModel
          ? product
          : ProductModel(
              name: product.name,
              id: product.id,
              quantity: product.quantity,
              unit: product.unit,
              priority: product.priority,
              urgent: product.urgent,
              checked: product.checked,
              remindEveryDay: product.remindEveryDay,
              addedBy: product.addedBy,
            );
      await apiClient.addItem(listId: lid, product: prod);
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> createList({
    required String name,
    String? fid,
  }) async {
    try {
      await apiClient.createList(body: {'name': name, 'family-id': fid});
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteList({required String lid}) async {
    try {
      await apiClient.deleteList(listId: lid);
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListsArrayEntity>> getFamilyLists({
    required String fid,
  }) async {
    try {
      final response = await apiClient.getFamilyPreviewShoppingList(
        familyId: fid,
      );
      return Right(response);
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> getList({required String lid}) async {
    try {
      final response = await apiClient.getList(listId: lid);
      return Right(response);
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
