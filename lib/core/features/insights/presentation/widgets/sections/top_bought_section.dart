import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Топ-5 локальных покупок; меньше двух позиций — секция скрыта.
class TopBoughtSection extends StatelessWidget {
  const TopBoughtSection({super.key, required this.top});

  final List<CountEntry> top;

  @override
  Widget build(BuildContext context) {
    if (top.length < 2) return const SizedBox.shrink();
    final max = top.first.count;
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(context.l10n.insightsTopBoughtTitle),
          PoraRowsCard(
            children: [
              for (final e in top.take(5))
                FrequencyRow(
                  name: e.name,
                  sub: '×${e.count}',
                  pct: max == 0 ? 0 : e.count / max,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
