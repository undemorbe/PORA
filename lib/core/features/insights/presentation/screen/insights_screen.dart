import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/ai_tip_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/features/insights/presentation/widgets/stat_card.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_chip.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Инсайты и ИИ-совет по вкусу пользователя.
@RoutePage()
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  static const _stats = <(String, String)>[
    ('23', 'продукта в неделю'),
    ('12', 'рецептов за месяц'),
    ('5', 'дней до закупки'),
  ];

  static const _freq = <(String, String, String, double)>[
    ('🥛', 'Молоко', '~раз в 7 дней', 0.85),
    ('🍞', 'Хлеб', '~раз в 3 дня', 0.95),
    ('☕', 'Кофе', '~раз в 14 дней', 0.55),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            6,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            Text(context.l10n.insightsTitle, style: PoraText.title),
            const SizedBox(height: PoraSpacing.lg),

            Row(
              children: [
                for (var i = 0; i < _stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(number: _stats[i].$1, label: _stats[i].$2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            AiTipCard(
              kicker: context.l10n.insightsTipKicker,
              title: context.l10n.insightsTipTitle,
              body: context.l10n.insightsTipBody,
              action: context.l10n.insightsTipAction,
            ),
            const SizedBox(height: PoraSpacing.xl),

            SectionLabel(context.l10n.insightsRunsOutMost),
            PoraRowsCard(
              children: [
                for (final (emoji, name, sub, pct) in _freq)
                  FrequencyRow(emoji: emoji, name: name, sub: sub, pct: pct),
              ],
            ),
            const SizedBox(height: PoraSpacing.xl),

            SectionLabel(context.l10n.insightsFavoriteCuisines),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                PoraChip(
                  label: context.l10n.insightsCuisineItalian,
                  leading: '🇮🇹',
                  dense: true,
                  selected: true,
                ),
                PoraChip(
                  label: context.l10n.insightsCuisinePasta,
                  leading: '🍝',
                  dense: true,
                ),
                PoraChip(
                  label: context.l10n.insightsCuisineBreakfasts,
                  leading: '🍳',
                  dense: true,
                ),
                PoraChip(
                  label: context.l10n.insightsCuisineLight,
                  leading: '🥗',
                  dense: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
