import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';

/// DTO для одной реплики в chat-completions.
/// Формат совпадает с OpenAI/OpenRouter: `{"role": "...", "content": "..."}`.
class AiMessageModel {
  const AiMessageModel({required this.role, required this.content});

  final String role;
  final String content;

  factory AiMessageModel.fromEntity(AiMessage m) =>
      AiMessageModel(role: m.role, content: m.content);

  Map<String, String> toJson() => {'role': role, 'content': content};
}
