import 'package:pora/core/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/core/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class ListsRepository {
  Future<Either<Failure, ListsArrayEntity>> getFamilyLists({
    required String fid,
  });
  Future<Either<Failure, Success>> createList({
    required String name,
    String? fid,
  });
  Future<Either<Failure, ListEntity>> getList({required String lid});
  Future<Either<Failure, Success>> deleteList({required String lid});
}
