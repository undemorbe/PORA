import 'package:pora/core/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/core/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetConcreteListUseCase {
  final ListsRepository listsRepository;

  const GetConcreteListUseCase({required this.listsRepository});

  Future<Either<Failure, ListEntity>> call({required String lid}) async {
    return await listsRepository.getList(lid: lid);
  }
}
