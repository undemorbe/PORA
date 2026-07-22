import 'package:pora/app/features/families/domain/entity/family.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class FamilyRepository {
  Future<Either<Failure, List<FamilyEntity>>> getFamilies();

  /// Возвращает id созданной family (backend response body).
  Future<Either<Failure, String>> createFamily({required String name});

  Future<Either<Failure, Success>> deleteFamily({required String familyId});
}
