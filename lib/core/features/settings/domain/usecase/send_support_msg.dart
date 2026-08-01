import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
import 'package:pora/core/features/settings/domain/repository/support_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class SendSupportMsgUseCase {

  final SupportRepository repository;

  const SendSupportMsgUseCase({required this.repository});

  Future<Either<Failure, Success>> call({
    required MessageEntity message
  }) async {
    return await repository.sendSupportMessage(message: message);
  }
}
