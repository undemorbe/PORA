import 'package:flutter/material.dart';
import 'package:pora/core/features/families/domain/entity/product.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Превью срочных продуктов: ряд компактных чипов «эмодзи + название».
/// Показывает не больше [maxVisible], остаток сворачивает в «+N».
class ProductPreview extends StatelessWidget {
  const ProductPreview({
    super.key,
    required this.products,
    this.maxVisible = 3,
  });

  final List<ProductEntity> products;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Text(
        context.l10n.familiesNoUrgent,
        style: PoraText.small.copyWith(color: context.colors.textSubtle),
      );
    }

    final visible = products.take(maxVisible).toList();
    final rest = products.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final p in visible) _ProductChip(emoji: p.emoji, name: p.name),
        if (rest > 0) _MoreChip(count: rest),
      ],
    );
  }
}

class _ProductChip extends StatelessWidget {
  const _ProductChip({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PoraColors.primaryTint,
        borderRadius: PoraRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            name,
            style: PoraText.micro.copyWith(color: PoraColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PoraColors.sandSoft,
        borderRadius: PoraRadii.pill,
      ),
      child: Text(
        '+$count',
        style: PoraText.micro.copyWith(color: PoraColors.textSecondary),
      ),
    );
  }
}
