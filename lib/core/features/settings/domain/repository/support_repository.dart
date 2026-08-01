import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class SupportRepository {
  Future<Either<Failure, Success>> sendSupportMessage({
    required MessageEntity message,
  });
}
