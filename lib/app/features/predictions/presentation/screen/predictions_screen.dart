import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/predictions/domain/entity/prediction.dart';
import 'package:pora/app/features/predictions/presentation/widgets/order_cta_card.dart';
import 'package:pora/app/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Экран «Пора докупить» — предсказания пополнения + CTA заказа.
/// Данные приходят из pora-ai (`GET /families/{id}/predictions`); пока демо.
@RoutePage()
class PredictionsPage extends StatelessWidget {
  const PredictionsPage({super.key});

  static const _predictions = <Prediction>[
    Prediction(
      emoji: '🥛',
      name: 'Молоко',
      meta: 'Покупаете ~раз в 7 дней · куплено 6 дней назад',
    ),
    Prediction(
      emoji: '☕',
      name: 'Кофе',
      meta: '~раз в 14 дней · куплено 12 дней назад',
    ),
    Prediction(
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
                      Text(context.l10n.predictionsTitle, style: PoraText.title),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.predictionsSubtitle,
                        style: PoraText.caption,
                      ),
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
            const SizedBox(height: PoraSpacing.xl),
            for (var i = 0; i < _predictions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: PoraSpacing.md),
                child: PredictionCard(
                  prediction: _predictions[i],
                  tileColor: _tiles[i],
                ),
              ),
            const SizedBox(height: PoraSpacing.sm),
            OrderCtaCard(
              onTap: () => AutoTabsRouter.of(context).setActiveIndex(2),
            ),
          ],
        ),
      ),
    );
  }
}
