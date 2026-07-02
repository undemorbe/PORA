import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Слот времени доставки (радио-выбор).
class SlotTile extends StatelessWidget {
  const SlotTile({
    super.key,
    required this.label,
    required this.price,
    required this.selected,
    this.onTap,
  });

  final String label;
  final String price;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? PoraColors.primaryTint
              : Theme.of(context).colorScheme.surface,
          borderRadius: PoraRadii.input,
          border: Border.all(
            color: selected ? PoraColors.primary : PoraColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? PoraColors.primary : PoraColors.toggleOff,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: PoraColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: PoraSpacing.md),
            Expanded(child: Text(label, style: PoraText.itemTitle)),
            Text(price, style: PoraText.small),
          ],
        ),
      ),
    );
  }
}
