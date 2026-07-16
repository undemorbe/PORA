import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
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
    this.onTap,
  });

  final String name;
  final String? qty;
  final bool added;
  final String? dup;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                      color: added ? c.ink : c.textSubtle,
                    ),
                  ),
                  if (qty != null)
                    Padding(
                      padding: const EdgeInsets.only(top: PoraSpacing.xxs),
                      child: Text(
                        qty!,
                        style: PoraText.small.copyWith(color: c.textSubtle),
                      ),
                    ),
                ],
              ),
            ),
            if (dup != null)
              PoraPill(
                label: dup!,
                background: c.surfaceAlt,
                foreground: c.textSubtle,
              ),
          ],
        ),
      ),
    );
  }
}
