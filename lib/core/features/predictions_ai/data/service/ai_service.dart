import 'package:pora/core/features/predictions_ai/data/datasource/ai_remote.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_message_model.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Реализация [AiRepository]. Мапит entity ↔ model, делегирует в [AiRemote].
class AiService implements AiRepository {
  const AiService({required this.remote});
  final AiRemote remote;

  @override
  Future<Either<Failure, AiCompletionEntity>> chat({
    required List<AiMessage> messages,
    int maxTokens = 400,
    double temperature = 0.6,
  }) async {
    final dtos = messages.map(AiMessageModel.fromEntity).toList();
    final res = await remote.chat(
      messages: dtos,
      maxTokens: maxTokens,
      temperature: temperature,
    );
    if (res.isLeft) return Left(res.left);
    return Right(res.right.toEntity());
  }
}
