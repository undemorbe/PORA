import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/prediction.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/ai_tip_of_day_card.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/kpi_row.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_chat_sheet.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_fab.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/prediction_card.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/section_header.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

@RoutePage()
class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  final StatisticsStore _store = GetIt.I<StatisticsStore>();
  final Set<String> _dismissed = <String>{};

  @override
  void initState() {
    super.initState();
    _store.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: PoraFab(onTap: () => openPoraChatSheet(context)),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: _store.loadAll,
          child: Observer(
            builder: (_) => ListView(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                PoraSpacing.sm,
                PoraSpacing.screen,
                120,
              ),
              children: [
                FadeSlideIn(
                  delay: const Duration(milliseconds: 40),
                  child: _Header(
                    title: l.predictionsGreeting,
                    subtitle: l.predictionsGreetingSub,
                    onInsights: () =>
                        context.router.push(const InsightsRoute()),
                  ),
                ),
                const SizedBox(height: PoraSpacing.lg),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: KpiRow(
                    items: [
                      KpiItem(
                        icon: PhosphorIconsRegular.basket,
                        number: '${_store.allProducts.length}',
                        label: l.kpiWeek,
                      ),
                      KpiItem(
                        icon: PhosphorIconsRegular.cookingPot,
                        number: '${_store.popularProducts.length}',
                        label: l.kpiRecipes,
                      ),
                      KpiItem(
                        icon: PhosphorIconsRegular.calendarBlank,
                        number: '${_soonProducts.length}',
                        label: l.kpiDaysToRun,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PoraSpacing.lg),
                const FadeSlideIn(
                  delay: Duration(milliseconds: 200),
                  child: AiTipOfDayCard(),
                ),
                const SizedBox(height: PoraSpacing.xl),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: SectionHeader(title: l.predictionsSectionSoon),
                ),
                const SizedBox(height: PoraSpacing.md),
                _SoonProducts(
                  products: _soonProducts,
                  isLoading: _store.isPopularLoading,
                  errorMessage: _store.popularError,
                  onDismiss: _dismiss,
                ),
                // const SizedBox(height: PoraSpacing.xl),
                // FadeSlideIn(
                //   delay: const Duration(milliseconds: 520),
                //   child: SectionHeader(title: l.predictionsSectionAiSuggests),
                // ),
                // const SizedBox(height: PoraSpacing.md),
                // const FadeSlideIn(
                //   delay: Duration(milliseconds: 580),
                //   child: AiSuggestionsCard(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopularProductEntity> get _soonProducts {
    final products =
        _store.popularProducts
            .where((product) => !_dismissed.contains(product.name))
            .where((product) => product.currentDay > 0)
            .toList()
          ..sort((a, b) => b.currentDay.compareTo(a.currentDay));
    if (products.isEmpty) {
      return _store.popularProducts
          .where((product) => !_dismissed.contains(product.name))
          .take(3)
          .toList();
    }
    return products.take(3).toList();
  }

  void _dismiss(String name) {
    setState(() => _dismissed.add(name));
  }
}

class _SoonProducts extends StatelessWidget {
  const _SoonProducts({
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.onDismiss,
  });

  final List<PopularProductEntity> products;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.md),
        child: Text(
          errorMessage ?? context.l10n.insightsEmpty,
          textAlign: TextAlign.center,
          style: PoraText.small.copyWith(color: context.colors.textSubtle),
        ),
      );
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          for (var index = 0; index < products.length; index++)
            FadeSlideIn(
              key: ValueKey(products[index].name),
              delay: Duration(milliseconds: index * 80),
              child: Padding(
                padding: const EdgeInsets.only(bottom: PoraSpacing.md),
                child: PredictionCard(
                  prediction: _prediction(context, products[index]),
                  tileColor: _tileColor(index),
                  onDismiss: () => onDismiss(products[index].name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PredictionEntity _prediction(
    BuildContext context,
    PopularProductEntity product,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final every = product.howOftenEnds > 0
        ? (locale == 'ru'
              ? '~раз в ${product.howOftenEnds} дней'
              : '~every ${product.howOftenEnds}d')
        : (locale == 'ru' ? 'Покупаете регулярно' : 'Bought regularly');
    final lastBought = product.currentDay > 0 && product.howOftenEnds > 0
        ? (product.howOftenEnds / product.currentDay).round()
        : 0;
    final meta = lastBought > 0
        ? (locale == 'ru'
              ? '$every · куплено $lastBought дн. назад'
              : '$every · bought ${lastBought}d ago')
        : every;
    return PredictionEntity(emoji: '🛒', name: product.name, meta: meta);
  }

  Color _tileColor(int index) {
    const colors = [
      PoraColors.sandSoft,
      PoraColors.sandMocha,
      PoraColors.sandWheat,
    ];
    return colors[index % colors.length];
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onInsights,
  });

  final String title;
  final String subtitle;
  final VoidCallback onInsights;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: PoraText.title),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: PoraText.caption.copyWith(
                  color: context.colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        _InsightsIconBtn(onTap: onInsights),
      ],
    );
  }
}

class _InsightsIconBtn extends StatelessWidget {
  const _InsightsIconBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border, width: 1),
        ),
        child: const Icon(
          PhosphorIconsRegular.chartLineUp,
          size: 20,
          color: PoraColors.primary,
        ),
      ),
    );
  }
}

