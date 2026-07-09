import 'package:dio/dio.dart';
import 'package:pora/app/features/invitation/domain/entity/link_code.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

abstract class RemoteInvitations {
  Future<Either<Failure, LinkCodeEntity>> getInviteCode({
    required String familyId,
  });
  Future<Either<Failure, Success>> connectWithInviteCode({
    required String code,
  });
}

class RemoteInvitationsImpl implements RemoteInvitations {
  final ApiClient apiClient;

  const RemoteInvitationsImpl({required this.apiClient});

  @override
  Future<Either<Failure, LinkCodeEntity>> getInviteCode({
    required String familyId,
  }) async {
    try {
      final result = await apiClient.getLinkCodeOfConcreteFamily(
        familyId: familyId,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Failed to get invite code'));
    }
  }

  @override
  Future<Either<Failure, Success>> connectWithInviteCode({
    required String code,
  }) async {
    try {
      await apiClient.joinFamily(code: code);
      return Right(const ServerSuccess());
    } on Exception catch (e) {
      return Left(NetworkFailure('Failed to connect with invite code: $e'));
    }
  }
}
