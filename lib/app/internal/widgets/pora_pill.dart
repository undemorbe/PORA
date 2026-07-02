import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Небольшая пилюля-метка: «Срочно», «Попробовать», «−15%» и т.п.
class PoraPill extends StatelessWidget {
  const PoraPill({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? PoraColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? PoraColors.primaryTint,
        borderRadius: PoraRadii.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            PhosphorIcon(icon!, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: PoraText.micro.copyWith(color: fg)),
        ],
      ),
    );
  }
}
