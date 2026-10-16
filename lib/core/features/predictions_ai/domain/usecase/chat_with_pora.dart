import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/chat_guard.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';
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
    String? contextSummary,
    AiContext context = const AiContext(),
  }) {
    final recentHistory = compactHistory(history);
    final guarded = guardedMessages(
      recentHistory,
      languageCode: languageCode,
      contextSummary: [
        contextSummary,
        context.summary,
      ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' '),
    );
    return repository.chat(messages: guarded, maxTokens: 3500);
  }

  static const historyWindow = 12;

  static final _recipeBlock = RegExp(
    r'<recipe>[\s\S]*?(?:</recipe>|$)',
    caseSensitive: false,
  );

  /// Последние [historyWindow] реплик; из прошлых ответов ассистента
  /// вырезается машинный `<recipe>{json}</recipe>` — модель видит текст
  /// рецепта, а JSON только съедал бы токены контекста. Окно начинается с
  /// реплики пользователя, чтобы модель не видела «ответ без вопроса».
  static List<AiMessage> compactHistory(List<AiMessage> history) {
    var recent = history.length <= historyWindow
        ? history
        : history.sublist(history.length - historyWindow);
    final firstUser = recent.indexWhere((m) => m.role == 'user');
    if (firstUser > 0) recent = recent.sublist(firstUser);
    return [
      for (final m in recent)
        if (m.role == 'assistant' &&
            m.content.toLowerCase().contains('<recipe>'))
          AiMessage.assistant(m.content.replaceAll(_recipeBlock, '').trim())
        else
          m,
    ];
  }
}
