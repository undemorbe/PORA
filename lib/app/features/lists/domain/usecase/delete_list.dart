import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class DeleteListUseCase {
  final ListsRepository listsRepository;

  const DeleteListUseCase({required this.listsRepository});

  Future<Either<Failure, Success>> call({required String lid}) async {
    return await listsRepository.deleteList(lid: lid);
  }
}
