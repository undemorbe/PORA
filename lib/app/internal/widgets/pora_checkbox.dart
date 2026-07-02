import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Скруглённый чекбокс товара в списке.
class PoraCheckbox extends StatelessWidget {
  const PoraCheckbox({super.key, required this.checked, this.onTap});

  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: PoraSizes.checkbox,
        height: PoraSizes.checkbox,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: checked
              ? PoraColors.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: PoraRadii.sm,
          border: checked
              ? null
              : Border.all(color: PoraColors.toggleOff, width: 1.5),
        ),
        child: checked
            ? const PhosphorIcon(
                PhosphorIconsBold.check,
                size: 15,
                color: PoraColors.inkInverse,
              )
            : null,
      ),
    );
  }
}
