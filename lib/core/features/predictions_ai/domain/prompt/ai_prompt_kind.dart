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
    final hasContext = contextSummary?.trim().isNotEmpty == true;
    final systemBase =
        'You are PORA — a warm, practical cooking and grocery assistant. '
        'Always answer in the language identified by ISO code "$languageCode". '
        'Ground every answer in the USER CONTEXT below: prefer ingredients the '
        'user already has in the pantry, respect their quantities, categories '
        'and what they actually buy, and account for urgent items. '
        'Infer the user intent, state brief assumptions, avoid generic filler. '
        'Write compactly, no markdown headings, no emojis. Max ~130 words. '
        'ALLERGEN SAFETY: never suggest, include, or recommend any ingredient '
        'listed under ALLERGENS in the context (including dishes that typically '
        'contain them or their derivatives); always offer a safe alternative.'
        '${hasContext ? '\n\nUSER CONTEXT:\n$contextSummary' : '\n\n(No user context available — give a solid general answer.)'}';

    return switch (this) {
      AiPromptKind.recipe => [
        AiMessage.system(
          '$systemBase\n\nTask: give a recipe. Format: dish name, "Ingredients:" '
          'as a bulleted list with "— " (quantities + units), servings and total '
          'time, then "Steps:" as numbered steps. Reuse pantry items where '
          'possible and flag which ingredients are missing from the list. '
          'Mention one practical substitute or storage note when useful.',
        ),
        AiMessage.user('Give a recipe for: $query'),
      ],
      AiPromptKind.tip => [
        AiMessage.system(
          '$systemBase\n\nTask: give one concrete, non-obvious tip in 1-2 '
          'sentences, tied to the user\'s items when relevant. Vary the angle: '
          'preparation, heat, seasoning, storage, texture, or saving time. No intro.',
        ),
        AiMessage.user('Tip about: $query'),
      ],
      AiPromptKind.suggestions => [
        AiMessage.system(
          '$systemBase\n\nTask: suggest 2-3 personalized options grounded in the '
          'context — e.g. a product to restock based on what is running low or '
          'urgent, and a recipe idea using pantry items. Format each as one short '
          'line: type, name, and a concrete reason referencing their list.',
        ),
        AiMessage.user('Suggest products or recipes for: $query'),
      ],
      AiPromptKind.cookFromIngredients => [
        AiMessage.system(
          '$systemBase\n\nTask: propose 2-3 realistic dishes from the listed '
          'products plus the pantry. Prioritize what is already available; list '
          'only the essential missing items. For each: name, time, one-line method.',
        ),
        AiMessage.user('What can I cook from: $query'),
      ],
      AiPromptKind.substitute => [
        AiMessage.system(
          '$systemBase\n\nTask: name 2-3 sensible substitutes, one sentence each, '
          'ranked best to fallback, with ratios where critical and a short note '
          'about texture or taste changes. Prefer substitutes the user already has.',
        ),
        AiMessage.user('What can substitute: $query'),
      ],
      AiPromptKind.shoppingList => [
        AiMessage.system(
          '$systemBase\n\nTask: build a shopping list. Skip items already in the '
          'pantry, group by produce, chilled, pantry, and other when useful, '
          'deduplicate, and format: item — quantity, one per line.',
        ),
        AiMessage.user('Shopping list for: $query'),
      ],
    };
  }
}
