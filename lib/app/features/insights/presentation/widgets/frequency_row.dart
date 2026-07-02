import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Строка частотности покупки продукта с прогресс-баром.
class FrequencyRow extends StatelessWidget {
  const FrequencyRow({
    super.key,
    required this.emoji,
    required this.name,
    required this.sub,
    required this.pct,
  });

  final String emoji;
  final String name;
  final String sub;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: 13,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: PoraSpacing.md),
          SizedBox(
            width: 82,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: PoraText.itemTitle),
                Text(sub, style: PoraText.small),
              ],
            ),
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: const Color(0xFFEFE4D4),
                color: PoraColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
