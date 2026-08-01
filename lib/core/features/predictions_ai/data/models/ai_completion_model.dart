import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';

/// DTO chat-completions ответа. Читает `choices[0].message.content`.
/// Кидает [FormatException] при отсутствии обязательных полей —
/// remote-слой переводит это в `ServerFailure`.
class AiCompletionModel {
  const AiCompletionModel({required this.content});

  final String content;

  factory AiCompletionModel.fromJson(Map<String, dynamic> json) {
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw const FormatException('Empty choices');
    }
    final first = choices.first as Map<String, dynamic>;
    final msg = first['message'] as Map<String, dynamic>?;
    final content = msg?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw const FormatException('Empty content');
    }
    return AiCompletionModel(content: content.trim());
  }

  AiCompletionEntity toEntity() => AiCompletionEntity(content: content);
}
