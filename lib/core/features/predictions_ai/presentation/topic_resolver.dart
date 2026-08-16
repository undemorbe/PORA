import 'package:pora/core/features/predictions_ai/domain/tip/tip_topic.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';

/// Разрешает `TipTopic` в человекочитаемую строку под текущую локаль.
class TopicResolver {
  const TopicResolver._();

  static String resolve(TipTopic topic, AppLocalizations l) {
    if (topic.isCustom) return topic.rawText ?? '';
    return _lookup(topic.l10nKey!, l);
  }

  static String _lookup(String key, AppLocalizations l) => switch (key) {
        'tipTopicHerbs' => l.tipTopicHerbs,
        'tipTopicBaking' => l.tipTopicBaking,
        'tipTopicSoups' => l.tipTopicSoups,
        'tipTopicMeat' => l.tipTopicMeat,
        'tipTopicFish' => l.tipTopicFish,
        'tipTopicVegetables' => l.tipTopicVegetables,
        'tipTopicStorage' => l.tipTopicStorage,
        'tipTopicKitchenHacks' => l.tipTopicKitchenHacks,
        'tipTopicSpices' => l.tipTopicSpices,
        'tipTopicDough' => l.tipTopicDough,
        'tipTopicBreakfast' => l.tipTopicBreakfast,
        'tipTopicDinner' => l.tipTopicDinner,
        _ => l.aiTipOfDayTopic,
      };
}
