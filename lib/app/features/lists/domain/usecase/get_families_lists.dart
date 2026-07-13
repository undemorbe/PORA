import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class GetFamiliesListsUseCase {
  final ListsRepository listsRepository;

  const GetFamiliesListsUseCase({required this.listsRepository});

  Future<Either<Failure, ListsArrayEntity>> call({required String fid}) async {
    return await listsRepository.getFamilyLists(fid: fid);
  }
}
