import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_icon_tile.dart';

/// Строка результата поиска: плитка · название · кнопка добавить.
class ResultRow extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.emoji,
    required this.name,
    this.onAdd,
  });

  final String emoji;
  final String name;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          PoraIconTile.emoji(
            emoji,
            color: const Color(0xFFF7EFE2),
            size: 40,
            emojiSize: 20,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(child: Text(name, style: PoraText.itemTitle)),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: PoraColors.primary,
                borderRadius: PoraRadii.md,
              ),
              child: const PhosphorIcon(
                PhosphorIconsBold.plus,
                size: 18,
                color: PoraColors.inkInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
