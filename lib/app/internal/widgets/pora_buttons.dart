import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Основная (терракотовая) кнопка с тёплой тенью. Наследует ElevatedButtonTheme.
class PoraPrimaryButton extends StatelessWidget {
  const PoraPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? ElevatedButton(onPressed: onPressed, child: Text(label))
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: PhosphorIcon(icon!, size: 18),
            label: Text(label),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: PoraRadii.button,
        boxShadow: onPressed == null ? null : PoraShadows.warm,
      ),
      child: child,
    );
  }
}

/// Вторичная (контурная) кнопка на светлой поверхности.
class PoraOutlineButton extends StatelessWidget {
  const PoraOutlineButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(PoraSizes.buttonHeight),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: PoraColors.textSecondary,
        side: const BorderSide(color: PoraColors.borderStrong, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: PoraRadii.button),
        textStyle: PoraText.button,
      ),
      child: Text(label),
    );
  }
}
