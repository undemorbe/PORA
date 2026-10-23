import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/presentation/widgets/metric_tiles.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Вовлечённость за период + счётчики «за всё время» с сервера.
class EngagementSection extends StatelessWidget {
  const EngagementSection({
    super.key,
    required this.summary,
    required this.uniqueProducts,
    required this.remindersCount,
    required this.urgentCount,
  });

  final UsageSummary summary;
  final int uniqueProducts;
  final int remindersCount;
  final int urgentCount;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricTiles(
          tiles: [
            MetricTile(
              icon: PhosphorIconsRegular.listChecks,
              value: '${s.listsOpened}',
              label: l.insightsKpiListsOpened,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.plus,
              value: '${s.listsCreated}',
              label: l.insightsKpiListsCreated,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.cookingPot,
              value: '${s.recipes}',
              label: l.insightsKpiRecipes,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.chatCircleDots,
              value: '${s.aiMessages}',
              label: l.insightsKpiAi,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.trash,
              value: '${s.deleted}',
              label: l.insightsKpiDeleted,
            ),
          ],
        ),
        const SizedBox(height: PoraSpacing.xl),
        SectionLabel(l.insightsAllTimeTitle),
        MetricTiles(
          tiles: [
            MetricTile(
              icon: PhosphorIconsRegular.package,
              value: '$uniqueProducts',
              label: l.insightsStatsProducts,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.bellRinging,
              value: '$remindersCount',
              label: l.insightsKpiReminders,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.warning,
              value: '$urgentCount',
              label: l.insightsKpiUrgent,
            ),
          ],
        ),
      ],
    );
  }
}
