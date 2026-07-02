import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Выбираемый чип: продукты онбординга, разделы, единицы, кухни, фильтры.
class PoraChip extends StatelessWidget {
  const PoraChip({
    super.key,
    required this.label,
    this.selected = false,
    this.leading, // эмодзи слева
    this.dense = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final String? leading;
  final bool dense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: dense
            ? const EdgeInsets.symmetric(horizontal: 13, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? PoraColors.primaryTint
              : Theme.of(context).colorScheme.surface,
          borderRadius: PoraRadii.pill,
          border: Border.all(
            color: selected ? PoraColors.primary : PoraColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Text(leading!, style: TextStyle(fontSize: dense ? 13 : 15)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: kPoraFontFamily,
                fontSize: dense ? 13 : 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? PoraColors.primaryDark
                    : PoraColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
