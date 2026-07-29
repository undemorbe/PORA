import 'package:pora/core/features/families/domain/entity/family.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class FamilyRepository {
  Future<Either<Failure, List<FamilyEntity>>> getFamilies();

  /// Возвращает id созданной family (backend response body).
  Future<Either<Failure, String>> createFamily({required String name});

  Future<Either<Failure, Success>> deleteFamily({required String familyId});
}
