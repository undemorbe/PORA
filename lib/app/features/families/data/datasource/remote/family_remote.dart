import 'package:pora/app/features/families/data/models/families_models.dart';
import 'package:pora/app/features/families/data/models/family_model.dart';
import 'package:pora/app/features/families/data/models/member_model.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
import 'package:pora/app/internal/di/export.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

abstract class FamilyRemoteDataSource {
  Future<Either<Failure, List<FamilyEntity>>> getFamilies();
  Future<Either<Failure, Success>> createFamily({required String name});
  Future<Either<Failure, Success>> deleteFamily({required String familyId});
}

class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final ApiClient apiClient;

  const FamilyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<FamilyEntity>>> getFamilies() async {
    try {
      FamiliesModels response = await apiClient.getFamilies();
      return Right(response.families);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> createFamily({required String name}) async {
    try {
      await apiClient.createFamily(nameOfFamilyBody: {'name': name});
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteFamily({
    required String familyId,
  }) async {
    try {
      await apiClient.deleteFamily(familyId: familyId);
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
