import 'package:pora/app/features/families/domain/repository/family_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class DeleteFamilyUseCase {
  final FamilyRepository familyRepository;

  const DeleteFamilyUseCase({required this.familyRepository});

  Future<Either<Failure, Success>> call({required String familyId}) async {
    final response = await familyRepository.deleteFamily(familyId: familyId);
    if (response.isLeft) {
      return Left(response.left);
    }
    return Right(response.right);
  }
}
