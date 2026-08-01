import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';

/// Локальные fallback-советы для карточки «Совет дня» когда API не отвечает.
/// Список фиксированный, читается из l10n — 10 штук.
class FallbackTips {
  const FallbackTips._();

  static List<String> all(AppLocalizations l) => [
    l.fallbackTip1,
    l.fallbackTip2,
    l.fallbackTip3,
    l.fallbackTip4,
    l.fallbackTip5,
    l.fallbackTip6,
    l.fallbackTip7,
    l.fallbackTip8,
    l.fallbackTip9,
    l.fallbackTip10,
  ];

  /// Возвращает совет по индексу, стабильно детерминированному от [seed].
  /// Использовать вместо `Random()` — она недоступна в некоторых hot-путях,
  /// а нам достаточно псевдо-случайности от времени.
  static String pick(AppLocalizations l, int seed) {
    final list = all(l);
    final i = seed.abs() % list.length;
    return list[i];
  }
}
