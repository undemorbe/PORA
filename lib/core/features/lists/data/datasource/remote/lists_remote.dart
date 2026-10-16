import 'package:pora/core/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/core/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class ListsRemote {
  Future<Either<Failure, ListsArrayEntity>> getFamilyLists({
    required String fid,
  });

  /// Возвращает id созданного списка.
  Future<Either<Failure, String>> createList({
    required String name,
    String? fid,
  });
  Future<Either<Failure, ListEntity>> getList({required String lid});
  Future<Either<Failure, Success>> deleteList({required String lid});
}

class ListsRemoteImpl implements ListsRemote {
  final ApiClient apiClient;

  const ListsRemoteImpl({required this.apiClient});

  @override
  Future<Either<Failure, String>> createList({
    required String name,
    String? fid,
  }) async {
    try {
      final res = await apiClient.createList(
        body: {'family-id': fid, 'name': name},
      );
      final id = res is Map ? res['id'] : null;
      if (id is! String || id.isEmpty) {
        return Left(const ServerFailure('create-list: no id in response'));
      }
      return Right(id);
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
