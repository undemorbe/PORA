import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/themes_colors/dark_colors/app_colors_dark.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

extension AppColorsX on BuildContext {
  AppColors get colors {
    final dark = Theme.of(this).brightness == Brightness.dark;
    return dark ? AppColors._dark() : AppColors._light();
  }
}

class AppColors {
  const AppColors._({
    required this.ink,
    required this.inkInverse,
    required this.textMuted,
    required this.textSubtle,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.divider,
    required this.bg,
  });

  factory AppColors._light() => const AppColors._(
    ink: PoraColors.ink,
    inkInverse: PoraColors.inkInverse,
    textMuted: PoraColors.textMuted,
    textSubtle: PoraColors.textSubtle,
    surface: PoraColors.surface,
    surfaceAlt: PoraColors.surface,
    border: PoraColors.border,
    divider: PoraColors.divider,
    bg: PoraColors.cream,
  );

  factory AppColors._dark() => const AppColors._(
    ink: PoraColorsDark.ink,
    inkInverse: PoraColorsDark.inkInverse,
    textMuted: PoraColorsDark.textMuted,
    textSubtle: PoraColorsDark.textSubtle,
    surface: PoraColorsDark.surface,
    surfaceAlt: PoraColorsDark.surfaceAlt,
    border: PoraColorsDark.border,
    divider: PoraColorsDark.divider,
    bg: PoraColorsDark.bg,
  );

  final Color ink;
  final Color inkInverse;
  final Color textMuted;
  final Color textSubtle;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color divider;
  final Color bg;
}
