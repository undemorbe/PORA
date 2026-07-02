import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Плавающая пилюля «＋ Добавить» над нижней навигацией.
class AddListButton extends StatelessWidget {
  const AddListButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        decoration: BoxDecoration(
          color: PoraColors.primary,
          borderRadius: PoraRadii.pill,
          boxShadow: PoraShadows.warm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PhosphorIcon(
              PhosphorIconsBold.plus,
              size: 20,
              color: PoraColors.inkInverse,
            ),
            const SizedBox(width: PoraSpacing.sm),
            Text(
              'Добавить',
              style: PoraText.button.copyWith(color: PoraColors.inkInverse),
            ),
          ],
        ),
      ),
    );
  }
}
