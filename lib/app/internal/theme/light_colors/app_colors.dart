import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
//  COLORS
// -----------------------------------------------------------------------------
abstract class PoraColors {
  // Brand — терракот
  static const Color primary = Color(0xFFE07A5F); // основной акцент, кнопки
  static const Color primaryDark = Color(0xFFC2553B); // текст/нажатие на тинте
  static const Color primaryTint = Color(0xFFFAE7DF); // фон выбранного/чипа
  static const Color primaryTintStrong = Color(0xFFFBE3DC); // пилюля «Срочно»

  // Neutrals — тёплые
  static const Color cream = Color(0xFFFBF5EC); // фон экранов
  static const Color surface = Color(0xFFFFFFFF); // карточки
  static const Color ink = Color(0xFF3A332C); // основной текст
  static const Color inkInverse = Color(0xFFFFFFFF); // текст на акценте
  static const Color textMuted = Color(0xFF9B9082); // вторичный текст
  static const Color textSubtle = Color(0xFFA89E8F); // подписи, мета
  static const Color textSecondary = Color(
    0xFF6E655A,
  ); // текст на белых кнопках
  static const Color divider = Color(0xFFF1E8DB); // разделители в карточках
  static const Color border = Color(0xFFECE3D8); // обводка инпутов/чипов
  static const Color borderStrong = Color(
    0xFFE6DCCD,
  ); // обводка вторичных кнопок

  // Accents
  static const Color sage = Color(0xFF8AA38B); // второй участник, успех мягкий
  static const Color sand = Color(0xFFF4C66A); // плитки, превью
  static const Color sandSoft = Color(0xFFFCEBC9); // плитка предсказания
  static const Color sandMocha = Color(0xFFE7D9C5);
  static const Color sandWheat = Color(0xFFF4E4C6);
  static const Color success = Color(0xFF5E9A6F); // оформлен/доставлен
  static const Color successTint = Color(0xFFE6F0E6);
  static const Color danger = Color(0xFFC9544A); // удалить, выйти

  // Controls
  static const Color toggleOff = Color(
    0xFFD9CDBC,
  ); // выключенный тумблер/чекбокс
  static const Color progressTrack = Color(0xFFEFE3D4); // трек прогресса/дотов
  static const Color dark = Color(0xFF1D1B19); // кнопка Apple

  // Утилита: полупрозрачный «ink» (home indicator и т.п.)
  static Color inkAlpha(double a) => ink.withOpacity(a);
}

// -----------------------------------------------------------------------------
//  SHADOWS
// -----------------------------------------------------------------------------
abstract class PoraShadows {
  /// Мягкая тень карточки
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF5C4C38).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Тень под акцентной (терракотовой) кнопкой
  static List<BoxShadow> warm = [
    BoxShadow(
      color: PoraColors.primary.withOpacity(0.35),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  /// Усиленная тень (карточка заказа, FAB)
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: PoraColors.primary.withOpacity(0.40),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}
