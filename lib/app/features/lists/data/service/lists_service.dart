import 'package:pora/app/features/lists/data/datasource/remote/lists_remote.dart';
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
  }) {
    return listsRemote.addItemToList(lid: lid, product: product);
  }

  @override
  Future<Either<Failure, Success>> createList({
    required String name,
    String? fid,
  }) {
    return listsRemote.createList(name: name, fid: fid);
  }

  @override
  Future<Either<Failure, Success>> deleteList({required String lid}) {
    return listsRemote.deleteList(lid: lid);
  }

  @override
  Future<Either<Failure, ListsArrayEntity>> getFamilyLists({
    required String fid,
  }) {
    return listsRemote.getFamilyLists(fid: fid);
  }

  @override
  Future<Either<Failure, ListEntity>> getList({required String lid}) {
    return listsRemote.getList(lid: lid);
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
  }) {
    return listsRemote.updateItem(
      itemId: itemId,
      name: name,
      section: section,
      quantity: quantity,
      unit: unit,
      priority: priority,
      urgent: urgent,
      remindEveryDays: remindEveryDays,
    );
  }
}
