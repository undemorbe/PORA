import 'package:pora/core/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class CreateListUseCase {
  final ListsRepository listsRepository;

  const CreateListUseCase({required this.listsRepository});

  Future<Either<Failure, Success>> call({
    required String name,
    String? fid,
  }) async {
    return await listsRepository.createList(name: name, fid: fid);
  }
}
