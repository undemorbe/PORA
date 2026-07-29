import 'package:pora/core/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/core/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetFamiliesListsUseCase {
  final ListsRepository listsRepository;

  const GetFamiliesListsUseCase({required this.listsRepository});

  Future<Either<Failure, ListsArrayEntity>> call({required String fid}) async {
    return await listsRepository.getFamilyLists(fid: fid);
  }
}
