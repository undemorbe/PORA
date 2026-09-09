import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/ai_tip_of_day_card.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/kpi_row.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_chat_sheet.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_fab.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/predictions_header.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/soon_products.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/section_header.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

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
                  child: PredictionsHeader(
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
                SoonProducts(
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
