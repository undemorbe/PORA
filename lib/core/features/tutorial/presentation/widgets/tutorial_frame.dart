import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';

/// Общий контейнер-«экран» под каждую анимацию туториала.
/// Даёт единый бордер, фон, padding и clip.
class TutorialFrame extends StatelessWidget {
  const TutorialFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: PoraRadii.card,
        border: Border.all(color: c.border, width: 1),
      ),
      padding: const EdgeInsets.all(PoraSpacing.lg),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
    );
  }
}
