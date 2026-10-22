import 'package:pora/core/features/families/domain/repository/family_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class LeaveFamilyUseCase {
  final FamilyRepository familyRepository;

  const LeaveFamilyUseCase({required this.familyRepository});

  Future<Either<Failure, Success>> call({required String familyId}) =>
      familyRepository.leaveFamily(familyId: familyId);
}
