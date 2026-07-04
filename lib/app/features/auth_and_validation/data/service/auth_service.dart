import 'package:pora/app/features/auth_and_validation/JWT_access/data/models/tokens_model.dart';
import 'package:pora/app/features/auth_and_validation/JWT_access/domain/entity/tokens_entity.dart';
import 'package:pora/app/features/auth_and_validation/data/datasource/auth_remote.dart';
import 'package:pora/app/features/auth_and_validation/domain/repository/auth_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

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
  }) async {
    final value = await authRemote.verifyOtp(
      destination: destination,
      otp: otp,
    );
    if (value.isRight) {
      return Right(value.right);
    }
    return Left(value.left);
  }
}
