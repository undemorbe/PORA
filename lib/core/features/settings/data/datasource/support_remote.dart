import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class SupportRemote {
  Future<Either<Failure, Success>> sendSupportMessage({
    required MessageEntity message,
  });
}

class SupportRemoteImpl implements SupportRemote {
  final ApiClient apiClient;

  const SupportRemoteImpl({required this.apiClient});

  @override
  Future<Either<Failure, Success>> sendSupportMessage({
    required MessageEntity message,
  }) async {
    try {
      await apiClient.sendSupportMessage(
        body: {'title': message.title, 'message': message.message},
      );
      return Right(ServerSuccess('200'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
