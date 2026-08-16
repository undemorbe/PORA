import 'package:pora/core/features/predictions_ai/domain/prompt/ai_prompt_kind.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Генерирует один короткий кулинарный совет через `AiPromptKind.tip`.
class GenerateTipUseCase {
  const GenerateTipUseCase({required this.repository});
  final AiRepository repository;

  Future<Either<Failure, AiCompletionEntity>> call({
    required String topic,
    required String languageCode,
  }) {
    final messages = AiPromptKind.tip.messagesFor(
      topic,
      languageCode: languageCode,
    );
    return repository.chat(messages: messages, maxTokens: 400);
  }
}
