import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';

/// Кулинарные «режимы» поиска. Каждый режим — заранее заготовленный
/// system-prompt + шаблон user-prompt.
///
/// UI-строки (label/hint) — в `AiPromptPresentation` (presentation-слой).
enum AiPromptKind { recipe, tip, cookFromIngredients, substitute, shoppingList }

extension AiPromptKindMessages on AiPromptKind {
  /// Собирает список сообщений под запрос пользователя.
  /// [languageCode] — ISO 639-1 код (`ru`/`en`/…) для явного указания
  /// языка ответа модели.
  List<AiMessage> messagesFor(String query, {required String languageCode}) {
    final systemBase =
        'You are PORA — a short, practical cooking assistant. '
        'Always answer in the language identified by ISO code "$languageCode". '
        'Write compactly, no preamble, no markdown headings, no emojis. '
        'Max ~250 words.';
    return switch (this) {
      AiPromptKind.recipe => [
        AiMessage.system(
          '$systemBase Format: dish name, "Ingredients:" as a bulleted list '
          'with "— ", "Steps:" as numbered steps.',
        ),
        AiMessage.user('Give a recipe for: $query'),
      ],
      AiPromptKind.tip => [
        AiMessage.system(
          '$systemBase Give one concrete cooking tip in 1-3 sentences, no intro.',
        ),
        AiMessage.user('Tip about: $query'),
      ],
      AiPromptKind.cookFromIngredients => [
        AiMessage.system(
          '$systemBase Propose 2 quick dishes from the listed products. '
          'For each: name + one line about the method.',
        ),
        AiMessage.user('What can I cook from: $query'),
      ],
      AiPromptKind.substitute => [
        AiMessage.system(
          '$systemBase Name 2-3 sensible substitutes, one sentence each, '
          'with ratios where critical.',
        ),
        AiMessage.user('What can substitute: $query'),
      ],
      AiPromptKind.shoppingList => [
        AiMessage.system(
          '$systemBase Build a shopping list for the task. '
          'Format: item — quantity, one per line.',
        ),
        AiMessage.user('Shopping list for: $query'),
      ],
    };
  }
}
