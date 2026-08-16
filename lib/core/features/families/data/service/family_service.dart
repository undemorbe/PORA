import 'package:pora/core/features/families/data/datasource/remote/family_remote.dart';
import 'package:pora/core/features/families/domain/entity/family.dart';
import 'package:pora/core/features/families/domain/repository/family_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class FamilyService implements FamilyRepository {
  final FamilyRemoteDataSource familyRemoteDataSource;

  FamilyService({required this.familyRemoteDataSource});

  @override
  Future<Either<Failure, List<FamilyEntity>>> getFamilies() async {
    return await familyRemoteDataSource.getFamilies();
  }

  @override
  Future<Either<Failure, String>> createFamily({required String name}) =>
      familyRemoteDataSource.createFamily(name: name);

  @override
  Future<Either<Failure, Success>> deleteFamily({
    required String familyId,
  }) async {
    return await familyRemoteDataSource.deleteFamily(familyId: familyId);
  }
}
