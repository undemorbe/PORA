import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class GetConcreteListUseCase {
  final ListsRepository listsRepository;

  const GetConcreteListUseCase({required this.listsRepository});

  Future<Either<Failure, ListEntity>> call({required String lid}) async {
    return await listsRepository.getList(lid: lid);
  }
}
