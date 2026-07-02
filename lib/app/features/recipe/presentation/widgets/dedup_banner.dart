import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Баннер о снятых дубликатах при импорте рецепта.
class DedupBanner extends StatelessWidget {
  const DedupBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: PoraColors.primaryTint,
        borderRadius: PoraRadii.md,
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 16)),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: PoraText.caption.copyWith(
                color: PoraColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
