import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/added_by.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/info_row.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/prediction_insight_banner.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
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
            ScreenBackHeader(title: context.l10n.itemDetailName),
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
                  Text(context.l10n.itemDetailName, style: PoraText.title),
                  const SizedBox(height: PoraSpacing.xs),
                  Text(context.l10n.itemDetailSubtitle, style: PoraText.subtitle),
                ],
              ),
            ),
            const SizedBox(height: PoraSpacing.xxl),

            PoraRowsCard(
              children: [
                InfoRow(label: context.l10n.itemDetailAddedBy, trailing: const AddedBy()),
                InfoRow(label: context.l10n.itemDetailSection, value: context.l10n.itemDetailSectionValue),
                InfoRow(label: context.l10n.itemDetailQuantity, value: context.l10n.itemDetailQuantityValue),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            PoraRowsCard(
              children: [
                PoraSettingRow(
                  icon: PhosphorIconsRegular.clock,
                  label: context.l10n.itemDetailUrgent,
                  trailing: const PoraToggle(value: true),
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.arrowsClockwise,
                  label: context.l10n.itemDetailRemind,
                  subtitle: context.l10n.itemDetailRemindEvery,
                  trailing: const PoraToggle(value: true),
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            PredictionInsightBanner(
              text: context.l10n.itemDetailInsight,
            ),
            const SizedBox(height: PoraSpacing.xl),

            PoraPrimaryButton(label: context.l10n.itemDetailMarkBought, onPressed: () {}),
            const SizedBox(height: PoraSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  context.l10n.itemDetailDelete,
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
