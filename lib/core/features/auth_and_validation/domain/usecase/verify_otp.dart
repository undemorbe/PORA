import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/features/auth_and_validation/domain/repository/auth_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class VerifyOtpUseCase {
  final AuthRepository authRepository;

  VerifyOtpUseCase({required this.authRepository});

  Future<Either<Failure, TokensEntity>> call({
    required String destination,
    required String otp,
    required String? deviceToken,
    required String deviceType,
  }) {
    return authRepository.verifyOtp(
      destination: destination,
      otp: otp,
      deviceToken: deviceToken,
      deviceType: deviceType,
    );
  }
}
