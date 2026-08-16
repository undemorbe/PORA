import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

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
