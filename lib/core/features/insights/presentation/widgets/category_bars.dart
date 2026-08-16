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

/// Категории — плоский типографический layout: имя + процент справа + hairline
/// разделитель. Убран outer card-container (был card-in-card в insights),
/// emoji-avatar (OS-blob) и heading `Покупки по категориям` (дублировал
/// секцию `_SectionTitle` на insights screen).
class CategoryBars extends StatelessWidget {
  const CategoryBars({super.key, required this.items});
  final List<CategoryBar> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) _Row(item: item),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});
  final CategoryBar item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: PoraText.itemTitle,
                ),
              ),
              Text(
                '${(item.share * 100).round()}%',
                style: PoraText.small.copyWith(
                  color: c.textSubtle,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: item.share.clamp(0, 1)),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 4,
                backgroundColor: c.surfaceAlt,
                color: PoraColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
