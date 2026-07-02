import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_checkbox.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Строка ингредиента в разборе рецепта (с меткой-дублем).
class IngredientRow extends StatelessWidget {
  const IngredientRow({
    super.key,
    required this.name,
    this.qty,
    required this.added,
    this.dup,
  });

  final String name;
  final String? qty;
  final bool added;
  final String? dup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: 13,
      ),
      child: Row(
        children: [
          PoraCheckbox(checked: added),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: PoraText.itemTitle.copyWith(
                    color: added ? PoraColors.ink : PoraColors.textSubtle,
                  ),
                ),
                if (qty != null)
                  Padding(
                    padding: const EdgeInsets.only(top: PoraSpacing.xxs),
                    child: Text(qty!, style: PoraText.small),
                  ),
              ],
            ),
          ),
          if (dup != null)
            PoraPill(
              label: dup!,
              background: const Color(0xFFEFE6DA),
              foreground: PoraColors.textSubtle,
            ),
        ],
      ),
    );
  }
}
