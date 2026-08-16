import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class AuthRepository {
  Future<Either<Failure, Success>> sendOtp({required String destination});
  Future<Either<Failure, TokensEntity>> verifyOtp({
    required String destination,
    required String otp,
    required String? deviceToken,
    required String deviceType,
  });
}
