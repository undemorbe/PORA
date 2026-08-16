import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/insights/presentation/widgets/champion_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/features/insights/presentation/widgets/streak_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/weekly_heatmap.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Инсайты: реальные данные из `StatisticsStore` (backend statistics API).
/// Streak, champion, heatmap, popular — всё живое.
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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: _store.loadAll,
          child: Observer(
            builder: (_) => ListView(
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
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: StreakCard(days: _store.streakDays),
                ),
                const SizedBox(height: PoraSpacing.lg),
                if (_store.popularProducts.isNotEmpty)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: ChampionCard(
                      name: _store.popularProducts.first.name,
                      count: _store.popularProducts.first.quantity,
                    ),
                  ),
                const SizedBox(height: PoraSpacing.lg),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: WeeklyHeatmap(logins: _store.logins.toList()),
                ),
                const SizedBox(height: PoraSpacing.xl),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 360),
                  child: SectionLabel(l.insightsPopular),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: _PopularList(
                    products: _store.popularProducts.toList(),
                    isLoading: _store.isPopularLoading,
                    errorMessage: _store.popularError,
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

/// Список популярных продуктов. `pct` — quantity / topQuantity.
/// `sub` — «~раз в N дн.» из `howOftenEnds`.
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
