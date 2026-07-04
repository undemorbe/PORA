import 'package:pora/app/features/auth_and_validation/JWT_access/domain/entity/tokens_entity.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class AuthRepository {
  Future<Either<Failure, Success>> sendOtp({required String destination});
  Future<Either<Failure, TokensEntity>> verifyOtp({
    required String destination,
    required String otp,
  });
}
