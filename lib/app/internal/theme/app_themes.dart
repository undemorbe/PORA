
// -----------------------------------------------------------------------------
//  THEME
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/dark_colors/app_colors_dark.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';

abstract class PoraTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: PoraColors.primary,
      onPrimary: PoraColors.inkInverse,
      secondary: PoraColors.sage,
      onSecondary: PoraColors.inkInverse,
      error: PoraColors.danger,
      onError: PoraColors.inkInverse,
      surface: PoraColors.surface,
      onSurface: PoraColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: kPoraFontFamily,
      scaffoldBackgroundColor: PoraColors.cream,
      colorScheme: scheme,
      dividerColor: PoraColors.divider,
      textTheme: TextTheme(
        displaySmall: PoraText.display,
        headlineMedium: PoraText.title,
        titleLarge: PoraText.heading,
        titleMedium: PoraText.navTitle,
        bodyLarge: PoraText.bodyLarge,
        bodyMedium: PoraText.body,
        bodySmall: PoraText.caption,
        labelLarge: PoraText.button,
        labelSmall: PoraText.overline,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PoraColors.primary,
          foregroundColor: PoraColors.inkInverse,
          minimumSize: const Size.fromHeight(PoraSizes.buttonHeight),
          elevation: 0,
          textStyle: PoraText.button,
          shape: const RoundedRectangleBorder(borderRadius: PoraRadii.button),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: PoraColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: PoraRadii.input,
          borderSide: const BorderSide(color: PoraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PoraRadii.input,
          borderSide: const BorderSide(color: PoraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PoraRadii.input,
          borderSide: const BorderSide(color: PoraColors.primary, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(PoraColors.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? PoraColors.primary
              : PoraColors.toggleOff,
        ),
      ),
    );
  }
  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: PoraColorsDark.primary,
      onPrimary: PoraColorsDark.inkInverse,
      secondary: PoraColorsDark.sage,
      onSecondary: PoraColorsDark.inkInverse,
      error: PoraColorsDark.danger,
      onError: PoraColorsDark.inkInverse,
      surface: PoraColorsDark.surface,
      onSurface: PoraColorsDark.ink,
    );

    // Типографику берём общую, но перекрашиваем под тёмный фон.
    Color ink(Color _) => PoraColorsDark.ink;
    final tt = TextTheme(
      displaySmall: PoraText.display.copyWith(color: PoraColorsDark.ink),
      headlineMedium: PoraText.title.copyWith(color: PoraColorsDark.ink),
      titleLarge: PoraText.heading.copyWith(color: PoraColorsDark.ink),
      titleMedium: PoraText.navTitle.copyWith(color: PoraColorsDark.ink),
      bodyLarge: PoraText.bodyLarge.copyWith(color: PoraColorsDark.ink),
      bodyMedium: PoraText.body.copyWith(color: PoraColorsDark.ink),
      bodySmall: PoraText.caption.copyWith(color: PoraColorsDark.textSubtle),
      labelLarge: PoraText.button,
      labelSmall: PoraText.overline.copyWith(color: PoraColorsDark.textSubtle),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: kPoraFontFamily,
      scaffoldBackgroundColor: PoraColorsDark.bg,
      colorScheme: scheme,
      dividerColor: PoraColorsDark.divider,
      textTheme: tt,
      cardColor: PoraColorsDark.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PoraColorsDark.primary,
          foregroundColor: PoraColorsDark.inkInverse,
          minimumSize: const Size.fromHeight(PoraSizes.buttonHeight),
          elevation: 0,
          textStyle: PoraText.button,
          shape: const RoundedRectangleBorder(borderRadius: PoraRadii.button),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: PoraColorsDark.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: PoraRadii.input,
          borderSide: const BorderSide(color: PoraColorsDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PoraRadii.input,
          borderSide: const BorderSide(color: PoraColorsDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PoraRadii.input,
          borderSide:
              const BorderSide(color: PoraColorsDark.primary, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Color(0xFFF3ECE1)),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? PoraColorsDark.primary
              : PoraColorsDark.toggleOff,
        ),
      ),
    );
  }

}
