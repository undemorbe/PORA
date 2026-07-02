import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/added_by.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/info_row.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/prediction_insight_banner.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_icon_tile.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/pora_toggle.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';

/// Карточка товара: детали, тумблеры, инсайт предсказания, действия.
@RoutePage()
class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            PoraSpacing.sm,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            const ScreenBackHeader(title: 'Молоко'),
            const SizedBox(height: PoraSpacing.lg),

            Center(
              child: Column(
                children: [
                  PoraIconTile.emoji(
                    '🥛',
                    color: PoraColors.sand,
                    size: 80,
                    emojiSize: 40,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  const SizedBox(height: 14),
                  Text('Молоко', style: PoraText.title),
                  const SizedBox(height: PoraSpacing.xs),
                  Text('2 л · Молочное', style: PoraText.subtitle),
                ],
              ),
            ),
            const SizedBox(height: PoraSpacing.xxl),

            PoraRowsCard(
              children: const [
                InfoRow(label: 'Добавил(а)', trailing: AddedBy()),
                InfoRow(label: 'Раздел', value: 'Молочное'),
                InfoRow(label: 'Количество', value: '2 л'),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            PoraRowsCard(
              children: const [
                PoraSettingRow(
                  icon: PhosphorIconsRegular.clock,
                  label: 'Срочно',
                  trailing: PoraToggle(value: true),
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.arrowsClockwise,
                  label: 'Напоминать',
                  subtitle: 'Каждые 7 дней',
                  trailing: PoraToggle(value: true),
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            const PredictionInsightBanner(
              text:
                  'Покупаете ~раз в 7 дней · последний раз 6 дней назад. Скоро предложу докупить.',
            ),
            const SizedBox(height: PoraSpacing.xl),

            PoraPrimaryButton(label: 'Отметить купленным', onPressed: () {}),
            const SizedBox(height: PoraSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Удалить из списка',
                  style: PoraText.bodyLarge.copyWith(
                    color: PoraColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
