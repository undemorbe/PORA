/// Одна реплика в chat-completions запросе. Формат совпадает с OpenAI/OpenRouter:
/// `{"role": "system"|"user"|"assistant", "content": "..."}`.
class AiMessage {
  const AiMessage.system(this.content) : role = 'system';
  const AiMessage.user(this.content) : role = 'user';
  const AiMessage.assistant(this.content) : role = 'assistant';

  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}
