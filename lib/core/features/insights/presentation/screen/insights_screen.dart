import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/insights/presentation/widgets/activity_chart.dart';
import 'package:pora/core/features/insights/presentation/widgets/period_switch.dart';
import 'package:pora/core/features/insights/presentation/widgets/rhythm_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/categories_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/champion_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/due_soon_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/engagement_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/insights_header.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/kpi_grid.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/popular_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/top_bought_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/streak_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/weekly_heatmap.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/responsive.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Инсайты: локальная статистика пользования (`UsageTracker`) за выбранный
/// период + серверная статистика продуктов (`StatisticsStore`).
///
/// Каждый блок — свой `Observer` вокруг data-виджета из `widgets/sections/`:
/// смена периода/новое событие перерисовывает только зависящие секции.
@RoutePage()
class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final StatisticsStore _store = GetIt.I<StatisticsStore>();

  @override
  void initState() {
    super.initState();
    _store.loadAll();
  }

  void _setPeriod(int days) {
    if (days == _store.period) return;
    _store.setPeriod(days);
    AnalyticsService.instance.logInsightsPeriodChanged(days);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    var step = 0;
    // Каскад появления: каждая следующая секция чуть позже.
    Widget fade(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 40 + 40 * step++),
      child: child,
    );
    const gap = SizedBox(height: PoraSpacing.lg);
    const sectionGap = SizedBox(height: PoraSpacing.xl);

    return Scaffold(
      body: SafeArea(
        child: AdaptiveContainer(
          child: RefreshIndicator.adaptive(
            onRefresh: () => _store.loadAll(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                6,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              children: [
                fade(
                  InsightsHeader(
                    title: l.insightsTitle,
                    onBack: () => context.router.maybePop(),
                  ),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) => PeriodSwitch(
                      periods: insightsPeriods,
                      value: _store.period,
                      onChanged: _setPeriod,
                    ),
                  ),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) => StreakCard(
                      days: _store.usage.currentStreak,
                      best: _store.usage.bestStreak,
                    ),
                  ),
                ),
                const SizedBox(height: PoraSpacing.md),
                fade(
                  Observer(
                    builder: (_) => InsightsKpiGrid(summary: _store.usage),
                  ),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) => ActivityChart(points: _store.usage.series),
                  ),
                ),
                gap,
                fade(
                  Observer(builder: (_) => RhythmCard(summary: _store.usage)),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) =>
                        WeeklyHeatmap(activity: _store.usage.activityByDay),
                  ),
                ),
                fade(
                  Observer(
                    builder: (_) => DueSoonSection(items: _store.dueSoon),
                  ),
                ),
                fade(
                  Observer(
                    builder: (_) => ChampionSection(champion: _store.champion),
                  ),
                ),
                fade(
                  Observer(
                    builder: (_) =>
                        TopBoughtSection(top: _store.usage.topBought),
                  ),
                ),
                fade(
                  Observer(
                    builder: (_) =>
                        CategoriesSection(categories: _store.categories),
                  ),
                ),
                sectionGap,
                fade(SectionLabel(l.insightsEngagementTitle)),
                fade(
                  Observer(
                    builder: (_) => EngagementSection(
                      summary: _store.usage,
                      uniqueProducts: _store.uniqueProducts,
                      remindersCount: _store.remindersCount,
                      urgentCount: _store.urgentCount,
                    ),
                  ),
                ),
                sectionGap,
                fade(SectionLabel(l.insightsPopular)),
                fade(
                  Observer(
                    builder: (_) => PopularSection(
                      products: _store.popularProducts.toList(),
                      isLoading: _store.isPopularLoading,
                      errorMessage: _store.popularError,
                    ),
                  ),
                ),
                sectionGap,
                fade(
                  Text(
                    l.insightsLocalNote,
                    textAlign: TextAlign.center,
                    style: PoraText.micro.copyWith(
                      color: context.colors.textSubtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
