import 'package:pora/app/features/lists/data/datasource/remote/lists_remote.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class ListsService implements ListsRepository {
  final ListsRemote listsRemote;

  const ListsService({required this.listsRemote});

  @override
  Future<Either<Failure, Success>> createList({
    required String name,
    String? fid,
  }) => listsRemote.createList(name: name, fid: fid);

  @override
  Future<Either<Failure, Success>> deleteList({required String lid}) =>
      listsRemote.deleteList(lid: lid);

  @override
  Future<Either<Failure, ListsArrayEntity>> getFamilyLists({
    required String fid,
  }) => listsRemote.getFamilyLists(fid: fid);

  @override
  Future<Either<Failure, ListEntity>> getList({required String lid}) =>
      listsRemote.getList(lid: lid);
}
