import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/pora_icon_tile.dart';

/// Превью распознанного рецепта (плитка + название + мета).
class RecipePreviewCard extends StatelessWidget {
  const RecipePreviewCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.meta,
    required this.found,
  });

  final String emoji;
  final String title;
  final String meta;
  final String found;

  @override
  Widget build(BuildContext context) {
    return PoraCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        children: [
          PoraIconTile.emoji(
            emoji,
            color: PoraColors.sand,
            size: 64,
            emojiSize: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PoraText.button),
                const SizedBox(height: PoraSpacing.xs),
                Text(meta, style: PoraText.small),
                const SizedBox(height: PoraSpacing.xxs),
                Text(
                  found,
                  style: PoraText.small.copyWith(
                    color: PoraColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
