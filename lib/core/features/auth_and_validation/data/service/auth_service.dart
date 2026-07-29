import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/features/auth_and_validation/data/datasource/remote/auth_remote.dart';
import 'package:pora/core/features/auth_and_validation/domain/repository/auth_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class AuthService extends AuthRepository {
  final AuthRemote authRemote;

  AuthService({required this.authRemote});

  @override
  Future<Either<Failure, Success>> sendOtp({
    required String destination,
  }) async {
    final value = await authRemote.sendOtp(destination: destination);
    if (value.isRight) {
      return Right(value.right);
    }
    return Left(value.left);
  }

  @override
  Future<Either<Failure, TokensEntity>> verifyOtp({
    required String destination,
    required String otp,
    required String? deviceToken,
    required String deviceType,
  }) async {
    return authRemote.verifyOtp(
      destination: destination,
      otp: otp,
      deviceToken: deviceToken,
      deviceType: deviceType,
    );
  }
}
