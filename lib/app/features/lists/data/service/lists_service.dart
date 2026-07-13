import 'package:pora/app/features/lists/data/datasource/remote/lists_remote.dart';
import 'package:pora/app/features/lists/data/models/products/product_model.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class ListsService implements ListsRepository {
  final ListsRemote listsRemote;

  const ListsService({required this.listsRemote});

  @override
  Future<Either<Failure, Success>> addItemToList({
    required String lid,
    required ProductEntity product,
  }) async {
    try {
      ProductModel prod = ProductModel(
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
      await listsRemote.addItemToList(lid: lid, product: prod);
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
      await listsRemote.createList(name: name, fid: fid);
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteList({required String lid}) async {
    try {
      await listsRemote.deleteList(lid: lid);
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
      final response = await listsRemote.getFamilyLists(fid: fid);
      return Right(response.right);
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> getList({required String lid}) async {
    try {
      final response = await listsRemote.getList(lid: lid);
      return Right(response.right);
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
