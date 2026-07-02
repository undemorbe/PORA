import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/predictions/domain/entity/prediction.dart';
import 'package:pora/app/features/predictions/presentation/widgets/order_cta_card.dart';
import 'package:pora/app/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_bottom_nav.dart';

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
      bottomNavigationBar: const PoraBottomNav(current: PoraTab.pora),
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
            Text('Пора докупить', style: PoraText.title),
            const SizedBox(height: 6),
            Text(
              'Скоро закончится — по вашим покупкам',
              style: PoraText.caption,
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
            const OrderCtaCard(),
          ],
        ),
      ),
    );
  }
}
