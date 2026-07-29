import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions/domain/entity/prediction.dart';
import 'package:pora/core/features/predictions/presentation/widgets/order_cta_card.dart';
import 'package:pora/core/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

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
                      Text(
                        context.l10n.predictionsTitle,
                        style: PoraText.title,
                      ),
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
            PredictionOfProductOnRequest(
              onTap: () async {
                final dio = GetIt.I<Dio>();
                final items = await dio.get(
                  'https://019f6ed6-a9f9-7f44-9869-9dfea74c0b4f.tunnel4.com/api/user/statistics/products',
                );
                Logger.talker.debug(items.data);
                final airequest = await dio.post(
                  'https://openrouter.ai/api/v1/chat/completions',
                  options: Options(
                    headers: {
                      'Authorization':
                          'Bearer ${dotenv.get('OPEN_ROUTER_API')}',
                    },
                  ),
                  data: {
                    'model': 'inclusionai/ling-3.0-flash:free',
                    'messages': [
                      {
                        'role': 'user',
                        'content': 'What is the capital of France?',
                      },
                    ],
                  },
                );
                print(airequest.data);
              },
            ),
          ],
        ),
      ),
    );
  }
}
