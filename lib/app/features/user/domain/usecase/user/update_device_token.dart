import 'package:pora/app/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class UpdateDeviceTokenUseCase {
  final UserRepository repository;

  const UpdateDeviceTokenUseCase({required this.repository});

  Future<Either<Failure, Success>> call({
    required String deviceToken,
    required String deviceType,
  }) {
    return repository.updateDeviceToken(
      deviceToken: deviceToken,
      deviceType: deviceType,
    );
  }
}
