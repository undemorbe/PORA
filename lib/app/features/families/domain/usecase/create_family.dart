import 'package:pora/app/features/families/domain/repository/family_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class CreateFamilyUseCase {
  final FamilyRepository familyRepository;

  const CreateFamilyUseCase({required this.familyRepository});

  Future<Either<Failure, Success>> call({required String name}) async {
    final response = await familyRepository.createFamily(name: name);
    if (response.isLeft) {
      return Left(response.left);
    }
    return Right(response.right);
  }
}
