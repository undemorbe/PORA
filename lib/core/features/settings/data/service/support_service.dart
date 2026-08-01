import 'package:pora/core/features/settings/data/datasource/support_remote.dart';
import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
import 'package:pora/core/features/settings/domain/repository/support_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class SupportService implements SupportRepository {
  final SupportRemote remoteDataSource;

  const SupportService({required this.remoteDataSource});
  @override
  Future<Either<Failure, Success>> sendSupportMessage({
    required MessageEntity message,
  }) async {
    return await remoteDataSource.sendSupportMessage(message: message);
  }
}
