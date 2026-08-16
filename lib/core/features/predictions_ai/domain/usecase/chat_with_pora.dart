import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/chat_guard.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Одна реплика в чате: получает историю, оборачивает в guarded system-prompt,
/// возвращает ответ ассистента.
class ChatWithPoraUseCase {
  const ChatWithPoraUseCase({required this.repository});
  final AiRepository repository;

  Future<Either<Failure, AiCompletionEntity>> call({
    required List<AiMessage> history,
    required String languageCode,
  }) {
    final guarded = guardedMessages(history, languageCode: languageCode);
    return repository.chat(messages: guarded, maxTokens: 500);
  }
}
