import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/pora_icon_tile.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Карточка магазина-партнёра доставки.
class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    this.name = 'Самокат',
    this.subtitle = 'Доставка за 15 минут',
    this.badge = '−15%',
  });

  final String name;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return PoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          PoraIconTile.emoji(
            '🛒',
            color: PoraColors.primary,
            size: 42,
            emojiSize: 20,
            borderRadius: BorderRadius.circular(13),
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: PoraText.itemTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: PoraText.small),
              ],
            ),
          ),
          PoraPill(
            label: badge,
            background: PoraColors.successTint,
            foreground: PoraColors.success,
          ),
        ],
      ),
    );
  }
}
