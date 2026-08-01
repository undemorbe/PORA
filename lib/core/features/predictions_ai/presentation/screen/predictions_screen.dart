import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/prediction.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/prediction_card.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/tip_card.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

@RoutePage()
class PredictionsPage extends StatelessWidget {
  const PredictionsPage({super.key});

  static const _predictions = <PredictionEntity>[
    PredictionEntity(
      emoji: '🥛',
      name: 'Молоко',
      meta: 'Покупаете ~раз в 7 дней · куплено 6 дней назад',
    ),
    PredictionEntity(
      emoji: '☕',
      name: 'Кофе',
      meta: '~раз в 14 дней · куплено 12 дней назад',
    ),
    PredictionEntity(
      emoji: '🍞',
      name: 'Хлеб',
      meta: '~раз в 3 дня · куплено 2 дня назад',
    ),
  ];

  static const _tiles = <Color>[
    PoraColors.sandSoft,
    PoraColors.sandMocha,
    PoraColors.sandWheat,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Padding(
        padding: .only(bottom: 120),
        child: FloatingActionButton(
          child: PhosphorIcon(PhosphorIcons.robotDuotone),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            PoraSpacing.sm,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.predictionsTitle,
                        style: PoraText.title,
                      ),
                      const SizedBox(height: 6),
                      Text(context.l10n.predictionTip, style: PoraText.caption),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.router.push(const InsightsRoute()),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: PhosphorIcon(
                      PhosphorIconsRegular.chartLineUp,
                      size: 24,
                      color: PoraColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.sm),
            TipCard(title: 'title', subtitle: 'subtitle', onTap: () {}),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                context.l10n.predictionsSubtitle,
                style: PoraText.caption,
              ),
            ),
            const SizedBox(height: PoraSpacing.sm),
            for (var i = 0; i < _predictions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: PoraSpacing.md),
                child: PredictionCard(
                  prediction: _predictions[i],
                  tileColor: _tiles[i],
                ),
              ),
            const SizedBox(height: PoraSpacing.sm),
          ],
        ),
      ),
    );
  }
}
