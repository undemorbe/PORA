import 'package:pora/app/features/auth_and_validation/domain/repository/auth_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class SendOtpUseCase {
  final AuthRepository authRepository;

  SendOtpUseCase({required this.authRepository});

  Future<Either<Failure, Success>> call({required String destination}) async {
    return await authRepository.sendOtp(destination: destination);
  }
}
