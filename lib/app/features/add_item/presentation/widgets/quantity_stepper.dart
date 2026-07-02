import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Счётчик количества: − N + .
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    this.onDecrement,
    this.onIncrement,
  });

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(context, PhosphorIconsBold.minus, onDecrement),
        const SizedBox(width: PoraSpacing.lg),
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: kPoraFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: PoraColors.ink,
          ),
        ),
        const SizedBox(width: PoraSpacing.lg),
        _btn(context, PhosphorIconsBold.plus, onIncrement),
      ],
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: PoraRadii.sm,
          border: Border.all(color: PoraColors.border),
        ),
        child: PhosphorIcon(icon, size: 17, color: PoraColors.primaryDark),
      ),
    );
  }
}
