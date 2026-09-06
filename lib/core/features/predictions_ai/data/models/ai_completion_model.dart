import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';

/// DTO chat-completions ответа. Читает `choices[0].message.content`.
/// Кидает [FormatException] при отсутствии обязательных полей —
/// remote-слой переводит это в `ServerFailure`.
class AiCompletionModel {
  const AiCompletionModel({required this.content});

  final String content;

  factory AiCompletionModel.fromJson(Map<String, dynamic> json) {
    final providerError = _providerError(json['error']);
    if (providerError != null) {
      throw FormatException('AI provider error: $providerError');
    }

    final choices = json['choices'];
    if (choices is! List) {
      throw const FormatException('AI response does not contain choices');
    }
    if (choices.isEmpty) {
      final reason = json['finish_reason'];
      throw FormatException(
        reason == null
            ? 'AI provider returned no choices'
            : 'AI provider returned no choices (finish_reason: $reason)',
      );
    }

    final first = choices.first;
    if (first is! Map) {
      throw const FormatException('AI response contains an invalid choice');
    }
    final msg = first['message'];
    final content = msg is Map ? msg['content'] as String? : null;
    if (content == null || content.trim().isEmpty) {
      final finishReason = first['finish_reason'];
      throw FormatException(
        finishReason == null
            ? 'AI response contains empty content'
            : 'AI response contains empty content (finish_reason: $finishReason)',
      );
    }
    return AiCompletionModel(content: content.trim());
  }

  static String? _providerError(Object? raw) {
    if (raw is Map) {
      final message = raw['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final code = raw['code'];
      if (code != null) return 'code $code';
    }
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  AiCompletionEntity toEntity() => AiCompletionEntity(content: content);
}
