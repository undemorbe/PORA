import 'package:pora/core/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class DeleteListUseCase {
  final ListsRepository listsRepository;

  const DeleteListUseCase({required this.listsRepository});

  Future<Either<Failure, Success>> call({required String lid}) async {
    return await listsRepository.deleteList(lid: lid);
  }
}
