import 'package:pora/core/features/families/domain/entity/family.dart';
import 'package:pora/core/features/families/domain/repository/family_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetFamiliesUseCase {
  final FamilyRepository familyRepository;

  const GetFamiliesUseCase({required this.familyRepository});

  Future<Either<Failure, List<FamilyEntity>>> call() async {
    final response = await familyRepository.getFamilies();
    if (response.isLeft) {
      return Left(response.left);
    }
    return Right(response.right);
  }
}
