import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
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
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';

/// Главный экран AI-предсказаний. Layout сверху вниз:
///   1. Header (greeting + insights icon).
///   2. KPI mini-row (3 плитки — из insights).
///   3. AI «Совет дня» — auto-loaded карточка.
///   4. Секция «Скоро закончится» — карточки предсказаний.
///   5. Секция «Часто покупаете» — 3 частотных строки из insights.
///   6. FAB «Спросить PORA» — открывает `PoraChatSheet`.
@RoutePage()
class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  /// Pool из которого рисуются 3 активные карточки. При dismiss'е верхняя
  /// уходит, из хвоста подтягивается новая. Пока mock — потом заменится
  /// репозиторием предсказаний.
  static const _pool = <(String, PredictionEntity)>[
    ('sandSoft', PredictionEntity(
      emoji: '🥛',
      name: 'Молоко',
      meta: '~раз в 7 дней · куплено 6 дней назад',
    )),
    ('sandMocha', PredictionEntity(
      emoji: '☕',
      name: 'Кофе',
      meta: '~раз в 14 дней · куплено 12 дней назад',
    )),
    ('sandWheat', PredictionEntity(
      emoji: '🍞',
      name: 'Хлеб',
      meta: '~раз в 3 дня · куплено 2 дня назад',
    )),
    ('sandSoft', PredictionEntity(
      emoji: '🧀',
      name: 'Сыр',
      meta: '~раз в 10 дней · куплено 9 дней назад',
    )),
    ('sandMocha', PredictionEntity(
      emoji: '🥚',
      name: 'Яйца',
      meta: '~раз в 5 дней · куплено 4 дня назад',
    )),
    ('sandWheat', PredictionEntity(
      emoji: '🍎',
      name: 'Яблоки',
      meta: '~раз в 6 дней · куплено 5 дней назад',
    )),
    ('sandSoft', PredictionEntity(
      emoji: '🧈',
      name: 'Масло',
      meta: '~раз в 12 дней · куплено 11 дней назад',
    )),
  ];

  late final List<int> _visibleIndices = [0, 1, 2];
  int _nextPoolIndex = 3;

  static const _tilesByKey = <String, Color>{
    'sandSoft': PoraColors.sandSoft,
    'sandMocha': PoraColors.sandMocha,
    'sandWheat': PoraColors.sandWheat,
  };

  static const _freq = <(String, String, String, double)>[
    ('🥛', 'Молоко', '~раз в 7 дней', 0.85),
    ('🍞', 'Хлеб', '~раз в 3 дня', 0.95),
    ('☕', 'Кофе', '~раз в 14 дней', 0.55),
  ];

  void _rotate(int slot) {
    setState(() {
      if (_nextPoolIndex < _pool.length) {
        _visibleIndices[slot] = _nextPoolIndex;
        _nextPoolIndex++;
      } else {
        // Пул исчерпан — просто снимаем карточку.
        _visibleIndices.removeAt(slot);
      }
    });
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
        child: ListView(
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
                onInsights: () => context.router.push(const InsightsRoute()),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: KpiRow(
                items: [
                  KpiItem(
                    icon: PhosphorIconsRegular.basket,
                    number: '23',
                    label: l.kpiWeek,
                  ),
                  KpiItem(
                    icon: PhosphorIconsRegular.cookingPot,
                    number: '12',
                    label: l.kpiRecipes,
                  ),
                  KpiItem(
                    icon: PhosphorIconsRegular.calendarBlank,
                    number: '5',
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
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (var slot = 0; slot < _visibleIndices.length; slot++)
                    _RotatingSlot(
                      key: ValueKey(_visibleIndices[slot]),
                      slotIndex: slot,
                      poolIndex: _visibleIndices[slot],
                      pool: _pool,
                      tilesByKey: _tilesByKey,
                      onDismiss: () => _rotate(slot),
                    ),
                ],
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 520),
              child: SectionHeader(
                title: l.predictionsSectionOften,
                trailing: _InsightsLink(
                  onTap: () => context.router.push(const InsightsRoute()),
                ),
              ),
            ),
            const SizedBox(height: PoraSpacing.md),
            FadeSlideIn(
              delay: const Duration(milliseconds: 580),
              child: PoraRowsCard(
                children: [
                  for (final (emoji, name, sub, pct) in _freq)
                    FrequencyRow(emoji: emoji, name: name, sub: sub, pct: pct),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Один слот-контейнер с fade+slide на mount, keyed по `poolIndex` —
/// когда родитель заменяет индекс, новая карточка проиграет свою анимацию.
class _RotatingSlot extends StatelessWidget {
  const _RotatingSlot({
    super.key,
    required this.slotIndex,
    required this.poolIndex,
    required this.pool,
    required this.tilesByKey,
    required this.onDismiss,
  });

  final int slotIndex;
  final int poolIndex;
  final List<(String, PredictionEntity)> pool;
  final Map<String, Color> tilesByKey;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (colorKey, entity) = pool[poolIndex];
    return FadeSlideIn(
      key: ValueKey('slot-$slotIndex-pool-$poolIndex'),
      duration: const Duration(milliseconds: 340),
      dy: 16,
      child: Padding(
        padding: const EdgeInsets.only(bottom: PoraSpacing.md),
        child: PredictionCard(
          prediction: entity,
          tileColor: tilesByKey[colorKey] ?? PoraColors.sandSoft,
          onDismiss: onDismiss,
        ),
      ),
    );
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

class _InsightsLink extends StatelessWidget {
  const _InsightsLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.seeAll,
              style: PoraText.small.copyWith(
                color: PoraColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              PhosphorIconsRegular.caretRight,
              size: 14,
              color: PoraColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
