import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';

/// Кулинарные «режимы» поиска. Каждый режим — заранее заготовленный
/// system-prompt + шаблон user-prompt.
///
/// UI-строки (label/hint) — в `AiPromptPresentation` (presentation-слой).
enum AiPromptKind {
  recipe,
  tip,
  suggestions,
  cookFromIngredients,
  substitute,
  shoppingList,
}

extension AiPromptKindMessages on AiPromptKind {
  /// Собирает список сообщений под запрос пользователя.
  /// [languageCode] — ISO 639-1 код (`ru`/`en`/…) для явного указания
  /// языка ответа модели.
  List<AiMessage> messagesFor(
    String query, {
    required String languageCode,
    String? contextSummary,
  }) {
    final systemBase =
        'You are PORA — a warm, practical cooking and grocery assistant. '
        'Always answer in the language identified by ISO code "$languageCode". '
        'Infer the user intent, state assumptions briefly, and avoid generic filler. '
        'Write compactly, no markdown headings, no emojis. Max ~120 words. '
        'Never suggest ingredients listed as forbidden in the context.';
    final context = contextSummary?.trim().isNotEmpty == true
        ? '\nUser context: $contextSummary'
        : '';
    return switch (this) {
      AiPromptKind.recipe => [
        AiMessage.system(
          '$systemBase Format: dish name, "Ingredients:" as a bulleted list '
          'with "— ", servings and time, then "Steps:" as numbered steps. '
          'Mention one practical substitute or storage note when useful.',
        ),
        AiMessage.user('Give a recipe for: $query'),
      ],
      AiPromptKind.tip => [
        AiMessage.system(
          '$systemBase Give one concrete, non-obvious tip in 1-2 sentences. '
          'Choose a different angle when the topic is broad: preparation, '
          'heat, seasoning, storage, texture, or saving time. No intro.$context',
        ),
        AiMessage.user('Tip about: $query'),
      ],
      AiPromptKind.suggestions => [
        AiMessage.system(
          '$systemBase Suggest 2-3 personalized options using the user context: '
          'a product to buy or use, and a recipe idea. Format each as one short '
          'line with type, name, and reason. Do not recommend forbidden ingredients.'
          '$context',
        ),
        AiMessage.user('Suggest products or recipes for: $query'),
      ],
      AiPromptKind.cookFromIngredients => [
        AiMessage.system(
          '$systemBase Propose 2-3 realistic dishes from the listed products. '
          'Prioritize what is already available; list only essential missing items. '
          'For each: name, time, and one-line method.',
        ),
        AiMessage.user('What can I cook from: $query'),
      ],
      AiPromptKind.substitute => [
        AiMessage.system(
          '$systemBase Name 2-3 sensible substitutes, one sentence each, '
          'ranked from best to fallback, with ratios where critical and a '
          'short note about texture or taste changes.',
        ),
        AiMessage.user('What can substitute: $query'),
      ],
      AiPromptKind.shoppingList => [
        AiMessage.system(
          '$systemBase Build a shopping list for the task. '
          'Group it by produce, chilled, pantry, and other when useful. '
          'Deduplicate items and format: item — quantity, one per line.',
        ),
        AiMessage.user('Shopping list for: $query'),
      ],
    };
  }
}
