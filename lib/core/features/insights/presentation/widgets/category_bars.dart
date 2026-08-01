import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

class CategoryBar {
  const CategoryBar({
    required this.emoji,
    required this.name,
    required this.share,
  });
  final String emoji;
  final String name;
  final double share; // 0..1
}

/// Разбивка покупок по категориям — 5 горизонтальных баров.
class CategoryBars extends StatelessWidget {
  const CategoryBars({super.key, required this.items});
  final List<CategoryBar> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.card,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Покупки по категориям',
            style: PoraText.itemTitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PoraSpacing.md),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: PoraSpacing.md),
            _Row(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});
  final CategoryBar item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(child: Text(item.name, style: PoraText.small)),
            Text(
              '${(item.share * 100).round()}%',
              style: PoraText.small.copyWith(
                color: c.textSubtle,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: item.share.clamp(0, 1)),
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: c.surfaceAlt,
              color: PoraColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
