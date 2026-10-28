import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/stat_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

/// 2×N сетка ключевых метрик периода с трендом к прошлому периоду.
class InsightsKpiGrid extends StatelessWidget {
  const InsightsKpiGrid({super.key, required this.summary});

  final UsageSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = summary;
    final rate = s.completionRate;
    final avg = s.avgSessionMinutes;
    Widget row(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: PoraSpacing.md),
        Expanded(child: b),
      ],
    );
    return Column(
      children: [
        row(
          StatCard(
            number: '${s.added}',
            label: l.insightsKpiAdded,
            delta: UsageSummary.deltaPercent(s.added, s.prevAdded),
          ),
          StatCard(
            number: '${s.bought}',
            label: l.insightsKpiBought,
            delta: UsageSummary.deltaPercent(s.bought, s.prevBought),
          ),
        ),
        const SizedBox(height: PoraSpacing.md),
        row(
          StatCard(
            number: rate == null ? '—' : '${(rate * 100).round()}%',
            label: l.insightsKpiCompletion,
          ),
          StatCard(
            number: '${s.activeDays}/${s.periodDays}',
            label: l.insightsKpiActiveDays,
            delta: UsageSummary.deltaPercent(s.activeDays, s.prevActiveDays),
          ),
        ),
        const SizedBox(height: PoraSpacing.md),
        row(
          StatCard(number: '${s.minutes}', label: l.insightsKpiMinutes),
          StatCard(
            number: '${s.opens}',
            label: l.insightsKpiSessions,
            hint: avg == null || avg < 0.1
                ? null
                : l.insightsAvgSession(avg.toStringAsFixed(avg < 10 ? 1 : 0)),
          ),
        ),
      ],
    );
  }
}
