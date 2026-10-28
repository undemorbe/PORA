import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/features/insights/presentation/widgets/insight_card.dart';

/// Столбики «добавлено / куплено» по дням (или неделям для длинных
/// периодов). Высота нормализуется к максимуму ряда.
class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key, required this.points});

  final List<ActivityPoint> points;

  static const _chartHeight = 120.0;

  /// «Добавлено» — тёплый песочный, читаемый в обеих темах.
  static const _addedColor = PoraColors.sand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    var maxValue = 0;
    for (final p in points) {
      if (p.added > maxValue) maxValue = p.added;
      if (p.bought > maxValue) maxValue = p.bought;
    }
    final hasData = maxValue > 0;
    final fmt = intl.DateFormat.MMMd(locale);

    return InsightCard(
      title: l.insightsActivityTitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LegendSwatch(color: _addedColor),
          const SizedBox(width: 4),
          Text(l.insightsKpiAdded, style: _legendStyle(c)),
          const SizedBox(width: PoraSpacing.sm),
          const _LegendSwatch(color: PoraColors.primary),
          const SizedBox(width: 4),
          Text(l.insightsKpiBought, style: _legendStyle(c)),
        ],
      ),
      child: SizedBox(
        height: _chartHeight + 22,
        child: !hasData
            ? Center(
                child: Text(
                  l.insightsActivityEmpty,
                  style: PoraText.small.copyWith(color: c.textSubtle),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: _chartHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final p in points)
                          Expanded(
                            child: _BarPair(
                              point: p,
                              max: maxValue,
                              height: _chartHeight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        fmt.format(points.first.start),
                        style: _legendStyle(c),
                      ),
                      const Spacer(),
                      Text(
                        fmt.format(points.last.start),
                        style: _legendStyle(c),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  static TextStyle _legendStyle(AppColors c) =>
      PoraText.micro.copyWith(color: c.textSubtle);
}

class _BarPair extends StatelessWidget {
  const _BarPair({
    required this.point,
    required this.max,
    required this.height,
  });

  final ActivityPoint point;
  final int max;
  final double height;

  @override
  Widget build(BuildContext context) {
    final track = context.colors.surfaceAlt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _bar(point.added, ActivityChart._addedColor, track)),
          const SizedBox(width: 1),
          Expanded(child: _bar(point.bought, PoraColors.primary, track)),
        ],
      ),
    );
  }

  Widget _bar(int value, Color color, Color track) {
    final target = value == 0 ? 2.0 : (value / max * height).clamp(4.0, height);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: target),
      builder: (_, h, _) => Container(
        height: h,
        decoration: BoxDecoration(
          color: value == 0 ? track : color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
