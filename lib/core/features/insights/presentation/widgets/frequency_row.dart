import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Строка частотности покупки продукта с прогресс-баром.
/// [pct] нормализуется UI-слоем к 0..1 относительно топа списка.
class FrequencyRow extends StatelessWidget {
  const FrequencyRow({
    super.key,
    required this.name,
    required this.sub,
    required this.pct,
    this.emoji,
  });

  final String? emoji;
  final String name;
  final String sub;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: 13,
      ),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: PoraSpacing.md),
          ],
          SizedBox(
            width: 108,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: PoraText.itemTitle,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: PoraText.small.copyWith(color: c.textSubtle),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEFE4D4),
                  color: PoraColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
