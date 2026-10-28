import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/item_detail/domain/usecase/add_item.dart';
import 'package:pora/core/features/lists/presentation/widgets/list_picker_sheet.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_guard.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';
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
  TabsRouter? _tabs;
  bool _wasActive = true;

  @override
  void initState() {
    super.initState();
    _store.loadAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Вкладки AutoTabsScaffold живут постоянно — initState только на первом
    // показе. Обновляем данные на каждом возврате на вкладку (throttle и
    // «грязный» флаг после локальных изменений — внутри store).
    // Без AutoTabsRouter (вне shell'а) просто не подписываемся.
    final tabs = TabsRouterScope.of(context)?.controller;
    if (identical(tabs, _tabs)) return;
    _tabs?.removeListener(_onTabChanged);
    _tabs = tabs?..addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final active = _tabs?.current.name == PredictionsRoute.name;
    if (active && !_wasActive) _store.loadAll();
    _wasActive = active;
  }

  @override
  void dispose() {
    _tabs?.removeListener(_onTabChanged);
    super.dispose();
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
          // Жест пользователя — минуя throttle.
          onRefresh: () => _store.loadAll(force: true),
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
                        // Уникальные названия: один товар в двух списках
                        // или купленный повторно — один продукт.
                        number: '${_store.uniqueProducts}',
                        label: l.kpiWeek,
                      ),
                      KpiItem(
                        icon: PhosphorIconsRegular.repeat,
                        number: '${_store.popularProducts.length}',
                        label: l.kpiRecipes,
                      ),
                      KpiItem(
                        icon: PhosphorIconsRegular.warningCircle,
                        number: '$_runningOutCount',
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
                  onAdd: _addToList,
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

  /// Сколько товаров реально «скоро закончатся» (не капнутый до 3 список).
  int get _runningOutCount => _store.popularProducts
      .where((p) => !_dismissed.contains(p.name) && p.currentDay > 0)
      .length;

  void _dismiss(String name) {
    setState(() => _dismissed.add(name));
  }

  /// «＋ В список»: выбор списка → добавление товара с дефолтами.
  Future<void> _addToList(PopularProductEntity product) async {
    if (!await ConnectivityGuard.checkWrite(context)) return;
    if (!mounted) return;
    final lid = await showListPickerSheet(context);
    if (lid == null || !mounted) return;

    final res = await GetIt.I<AddItemUseCase>().call(
      listId: lid,
      name: product.name,
      section: AddItemDefaults.defaultSection,
      quantity: 1,
      unit: AddItemDefaults.defaultUnit,
      priority: 1,
      urgent: false,
      remindEveryDays: null,
    );
    if (!mounted) return;
    res.fold((f) => PoraSnackbar.show(context, message: f.message), (_) {
      PoraSnackbar.show(context, message: context.l10n.predictionsAdded);
      _dismiss(product.name);
    });
  }
}
