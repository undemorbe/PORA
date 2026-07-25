import 'package:pora/app/features/families/domain/repository/family_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class CreateFamilyUseCase {
  final FamilyRepository familyRepository;
  const CreateFamilyUseCase({required this.familyRepository});

  /// Возвращает id созданной family.
  Future<Either<Failure, String>> call({required String name}) =>
      familyRepository.createFamily(name: name);
}
