import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Абстракция транспорта AI. Скрывает провайдера (OpenRouter/OpenAI/иное) —
/// UI/usecase'ы работают только с этим контрактом.
abstract class AiRepository {
  /// Выполняет chat-completions запрос с переданным набором сообщений.
  /// [maxTokens]/[temperature] — управляемая длина/температура.
  Future<Either<Failure, AiCompletionEntity>> chat({
    required List<AiMessage> messages,
    int maxTokens,
    double temperature,
  });
}
