import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/presentation/widgets/ai_tip_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/category_bars.dart';
import 'package:pora/core/features/insights/presentation/widgets/champion_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/features/insights/presentation/widgets/streak_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/weekly_heatmap.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/pora_chip.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Инсайты: полезная визуализация — streak, champion, heatmap, category bars,
/// частотность, AI-совет, любимые кухни.
@RoutePage()
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  static const _freq = <(String, String, String, double)>[
    ('🥛', 'Молоко', '~раз в 7 дней', 0.85),
    ('🍞', 'Хлеб', '~раз в 3 дня', 0.95),
    ('☕', 'Кофе', '~раз в 14 дней', 0.55),
  ];

  static const _categories = [
    CategoryBar(emoji: '🥦', name: 'Овощи и фрукты', share: 0.32),
    CategoryBar(emoji: '🥛', name: 'Молочное', share: 0.24),
    CategoryBar(emoji: '🍝', name: 'Бакалея', share: 0.18),
    CategoryBar(emoji: '🥩', name: 'Мясо и рыба', share: 0.14),
    CategoryBar(emoji: '🧀', name: 'Разное', share: 0.12),
  ];

  static const _heatmap = <List<double>>[
    [0.2, 0.4, 0.1, 0.6, 0.9, 0.7, 0.3],
    [0.5, 0.2, 0.4, 0.8, 0.6, 0.1, 0.9],
    [0.1, 0.7, 0.5, 0.4, 0.8, 0.6, 0.2],
    [0.6, 0.3, 0.9, 0.5, 0.4, 0.8, 0.7],
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
            FadeSlideIn(
              delay: const Duration(milliseconds: 40),
              child: _Header(
                title: l.insightsTitle,
                onBack: () => context.router.maybePop(),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            const FadeSlideIn(
              delay: Duration(milliseconds: 120),
              child: StreakCard(days: 12),
            ),
            const SizedBox(height: PoraSpacing.lg),
            const FadeSlideIn(
              delay: Duration(milliseconds: 200),
              child: ChampionCard(emoji: '🥛', name: 'Молоко', count: 8),
            ),
            const SizedBox(height: PoraSpacing.lg),
            const FadeSlideIn(
              delay: Duration(milliseconds: 280),
              child: WeeklyHeatmap(data: _heatmap),
            ),
            const SizedBox(height: PoraSpacing.lg),
            const FadeSlideIn(
              delay: Duration(milliseconds: 360),
              child: CategoryBars(items: _categories),
            ),
            const SizedBox(height: PoraSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 440),
              child: AiTipCard(
                kicker: l.insightsTipKicker,
                title: l.insightsTipTitle,
                body: l.insightsTipBody,
                action: l.insightsTipAction,
              ),
            ),
            const SizedBox(height: PoraSpacing.xl),
            FadeSlideIn(
              delay: const Duration(milliseconds: 520),
              child: SectionLabel(l.insightsRunsOutMost),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 560),
              child: PoraRowsCard(
                children: [
                  for (final (emoji, name, sub, pct) in _freq)
                    FrequencyRow(emoji: emoji, name: name, sub: sub, pct: pct),
                ],
              ),
            ),
            const SizedBox(height: PoraSpacing.xl),
            FadeSlideIn(
              delay: const Duration(milliseconds: 620),
              child: SectionLabel(l.insightsFavoriteCuisines),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 660),
              child: Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  PoraChip(
                    label: l.insightsCuisineItalian,
                    leading: '🇮🇹',
                    dense: true,
                    selected: true,
                  ),
                  PoraChip(
                    label: l.insightsCuisinePasta,
                    leading: '🍝',
                    dense: true,
                  ),
                  PoraChip(
                    label: l.insightsCuisineBreakfasts,
                    leading: '🍳',
                    dense: true,
                  ),
                  PoraChip(
                    label: l.insightsCuisineLight,
                    leading: '🥗',
                    dense: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Icon(PhosphorIconsRegular.caretLeft, size: 26),
          ),
        ),
        const SizedBox(width: PoraSpacing.md),
        Text(title, style: PoraText.title),
      ],
    );
  }
}
