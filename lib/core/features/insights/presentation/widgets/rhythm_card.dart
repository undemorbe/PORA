import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/presentation/widgets/insight_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// «Ваш ритм»: распределение действий по частям суток + самый активный
/// день недели.
class RhythmCard extends StatelessWidget {
  const RhythmCard({super.key, required this.summary});

  final UsageSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final peak = summary.peakDayPart;
    final parts = summary.dayParts;
    final total = parts.values.fold<int>(0, (a, b) => a + b);
    final weekday = summary.peakWeekday;
    final locale = Localizations.localeOf(context).toString();

    return InsightCard(
      title: l.insightsRhythmTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (peak == null)
            Text(
              l.insightsNoUsageYet,
              style: PoraText.small.copyWith(color: c.textSubtle),
            )
          else ...[
            Text(_peakSentence(l, peak), style: PoraText.body),
            const SizedBox(height: PoraSpacing.md),
            Row(
              children: [
                for (final p in DayPart.values)
                  Expanded(
                    child: _PartColumn(
                      icon: _icon(p),
                      label: _label(l, p),
                      share: total == 0 ? 0 : (parts[p] ?? 0) / total,
                      highlighted: p == peak,
                    ),
                  ),
              ],
            ),
          ],
          if (weekday != null) ...[
            const SizedBox(height: PoraSpacing.md),
            Text(
              l.insightsPeakWeekday(
                intl.DateFormat.EEEE(
                  locale,
                ).format(DateTime(2024, 1, weekday)), // 2024-01-01 = пн
              ),
              style: PoraText.small.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  static String _peakSentence(AppLocalizations l, DayPart p) => switch (p) {
    DayPart.morning => l.insightsPeakMorning,
    DayPart.afternoon => l.insightsPeakAfternoon,
    DayPart.evening => l.insightsPeakEvening,
    DayPart.night => l.insightsPeakNight,
  };

  static String _label(AppLocalizations l, DayPart p) => switch (p) {
    DayPart.morning => l.insightsPartMorning,
    DayPart.afternoon => l.insightsPartAfternoon,
    DayPart.evening => l.insightsPartEvening,
    DayPart.night => l.insightsPartNight,
  };

  static IconData _icon(DayPart p) => switch (p) {
    DayPart.morning => PhosphorIconsRegular.sunHorizon,
    DayPart.afternoon => PhosphorIconsRegular.sun,
    DayPart.evening => PhosphorIconsRegular.moonStars,
    DayPart.night => PhosphorIconsRegular.moon,
  };
}

class _PartColumn extends StatelessWidget {
  const _PartColumn({
    required this.icon,
    required this.label,
    required this.share,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final double share;
  final bool highlighted;

  static const _maxBar = 56.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = highlighted ? PoraColors.primary : PoraColors.sand;
    return Column(
      children: [
        Text(
          '${(share * 100).round()}%',
          style: PoraText.micro.copyWith(
            color: highlighted ? PoraColors.primaryDark : c.textSubtle,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _maxBar,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: (share * _maxBar).clamp(4, _maxBar)),
              builder: (_, h, _) => Container(
                width: 28,
                height: h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Icon(
          icon,
          size: 16,
          color: highlighted ? PoraColors.primary : c.textMuted,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: PoraText.micro.copyWith(color: c.textMuted),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
