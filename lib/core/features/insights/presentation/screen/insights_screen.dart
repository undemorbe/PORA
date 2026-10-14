import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/insights/presentation/widgets/activity_chart.dart';
import 'package:pora/core/features/insights/presentation/widgets/category_bars.dart';
import 'package:pora/core/features/insights/presentation/widgets/champion_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/due_soon_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/features/insights/presentation/widgets/insight_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/metric_tiles.dart';
import 'package:pora/core/features/insights/presentation/widgets/period_switch.dart';
import 'package:pora/core/features/insights/presentation/widgets/rhythm_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/stat_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/streak_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/weekly_heatmap.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/responsive.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Инсайты: локальная статистика пользования (`UsageTracker`) за выбранный
/// период + серверная статистика продуктов (`StatisticsStore`).
///
/// Каждый блок — свой `Observer`: смена периода/новое событие перерисовывает
/// только зависящие от них секции.
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
                  _Header(
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
                fade(Observer(builder: (_) => _KpiGrid(summary: _store.usage))),
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
                fade(Observer(builder: (_) => _DueSoonSection(store: _store))),
                fade(Observer(builder: (_) => _ChampionSection(store: _store))),
                fade(
                  Observer(builder: (_) => _TopBoughtSection(store: _store)),
                ),
                fade(
                  Observer(builder: (_) => _CategoriesSection(store: _store)),
                ),
                sectionGap,
                fade(SectionLabel(l.insightsEngagementTitle)),
                fade(Observer(builder: (_) => _Engagement(store: _store))),
                sectionGap,
                fade(SectionLabel(l.insightsPopular)),
                fade(
                  Observer(
                    builder: (_) => _PopularList(
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

/// 2×N сетка ключевых метрик периода с трендом к прошлому периоду.
class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});

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

class _DueSoonSection extends StatelessWidget {
  const _DueSoonSection({required this.store});
  final StatisticsStore store;

  @override
  Widget build(BuildContext context) {
    final items = store.dueSoon;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(context.l10n.insightsDueSoonTitle),
          DueSoonCard(items: items),
        ],
      ),
    );
  }
}

class _ChampionSection extends StatelessWidget {
  const _ChampionSection({required this.store});
  final StatisticsStore store;

  @override
  Widget build(BuildContext context) {
    // Сервер видит покупки со всех устройств; локальный топ — запасной.
    final server = store.popularProducts;
    final local = store.usage.topBought;
    final String name;
    final int count;
    if (server.isNotEmpty && server.first.quantity > 0) {
      name = server.first.name;
      count = server.first.quantity;
    } else if (local.isNotEmpty) {
      name = local.first.name;
      count = local.first.count;
    } else {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.lg),
      child: ChampionCard(name: name, count: count),
    );
  }
}

class _TopBoughtSection extends StatelessWidget {
  const _TopBoughtSection({required this.store});
  final StatisticsStore store;

  @override
  Widget build(BuildContext context) {
    final top = store.usage.topBought;
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

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.store});
  final StatisticsStore store;

  @override
  Widget build(BuildContext context) {
    final cats = store.categories;
    if (cats.isEmpty) return const SizedBox.shrink();
    final total = cats.fold<int>(0, (a, e) => a + e.count);
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.lg),
      child: InsightCard(
        title: context.l10n.insightsCategoriesTitle,
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.lg,
          PoraSpacing.lg,
          PoraSpacing.lg,
          PoraSpacing.sm,
        ),
        child: CategoryBars(
          items: [
            for (final c in cats)
              CategoryBar(
                name: c.name,
                share: total == 0 ? 0 : c.count / total,
              ),
          ],
        ),
      ),
    );
  }
}

class _Engagement extends StatelessWidget {
  const _Engagement({required this.store});
  final StatisticsStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = store.usage;
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
              value: '${store.uniqueProducts}',
              label: l.insightsStatsProducts,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.bellRinging,
              value: '${store.remindersCount}',
              label: l.insightsKpiReminders,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.warning,
              value: '${store.urgentCount}',
              label: l.insightsKpiUrgent,
            ),
          ],
        ),
      ],
    );
  }
}

class _PopularList extends StatelessWidget {
  const _PopularList({
    required this.products,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<PopularProductEntity> products;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: PoraSpacing.lg),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.md),
        child: Text(
          errorMessage ?? context.l10n.insightsEmpty,
          style: PoraText.small.copyWith(color: context.colors.textSubtle),
          textAlign: TextAlign.center,
        ),
      );
    }
    final l = context.l10n;
    final top = products.first.quantity;
    return PoraRowsCard(
      children: [
        for (final p in products.take(6))
          FrequencyRow(
            name: p.name,
            sub: p.howOftenEnds > 0
                ? l.insightsFreqEvery(p.howOftenEnds)
                : '×${p.quantity}',
            pct: top == 0 ? 0 : p.quantity / top,
          ),
      ],
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
        Semantics(
          button: true,
          label: MaterialLocalizations.of(context).backButtonTooltip,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Icon(PhosphorIconsRegular.caretLeft, size: 26),
            ),
          ),
        ),
        const SizedBox(width: PoraSpacing.md),
        Text(title, style: PoraText.title),
      ],
    );
  }
}
