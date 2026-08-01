/// Фиксированный список l10n-ключей предзаданных тем совета.
/// Каждый ключ должен существовать в ARB (`app_ru`/`app_en`).
class PredefinedTipTopics {
  const PredefinedTipTopics._();

  static const List<String> keys = [
    'tipTopicHerbs',
    'tipTopicBaking',
    'tipTopicSoups',
    'tipTopicMeat',
    'tipTopicFish',
    'tipTopicVegetables',
    'tipTopicStorage',
    'tipTopicKitchenHacks',
    'tipTopicSpices',
    'tipTopicDough',
    'tipTopicBreakfast',
    'tipTopicDinner',
  ];
}
