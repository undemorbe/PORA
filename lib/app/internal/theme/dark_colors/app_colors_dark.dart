
import 'package:flutter/material.dart';


// -----------------------------------------------------------------------------
//  DARK COLORS  (зеркало PoraColors, тёмные значения)
// -----------------------------------------------------------------------------
abstract class PoraColorsDark {
  // Поверхности (elevation светлеет, без жёстких теней)
  static const Color bg = Color(0xFF16120D); // тёплый почти-чёрный фон
  static const Color surface = Color(0xFF221C16); // карточки
  static const Color surfaceAlt = Color(0xFF2B241C); // поля ввода, raised-пилюли
  static const Color divider = Color(0xFF322A21); // разделители
  static const Color border = Color(0xFF3A3128); // обводки

  // Текст
  static const Color ink = Color(0xFFF3ECE1); // основной текст (тёплый белый)
  static const Color textMuted = Color(0xFFADA08E); // вторичный
  static const Color textSubtle = Color(0xFF847A6C); // подписи/мета

  // Brand — терракот, чуть светлее для контраста на тёмном
  static const Color primary = Color(0xFFE8896C);
  static const Color primaryDark = Color(0xFFC2553B);
  static const Color primaryTint = Color(0xFF3A241C); // фон выбранного/чипа
  static const Color onPrimaryTint = Color(0xFFF0A98E); // текст на тинте

  // Акценты и статусы (подсветлены под тёмный фон)
  static const Color sage = Color(0xFF9DB79E);
  static const Color sand = Color(0xFFE8C173);
  static const Color success = Color(0xFF6FB382);
  static const Color successTint = Color(0xFF233022);
  static const Color danger = Color(0xFFE5786E);

  // Controls
  static const Color toggleOff = Color(0xFF463D32);
  static const Color progressTrack = Color(0xFF322A21);
  static const Color inkInverse = Color(0xFF1A140F); // тёмный текст на светлом акценте

  static Color inkAlpha(double a) => ink.withOpacity(a);
}

// -----------------------------------------------------------------------------
//  DARK SHADOWS  (на тёмном тени почти невидимы — используем глубокий чёрный,
//  а «приподнятость» даём более светлой поверхностью surface/surfaceAlt)
// -----------------------------------------------------------------------------
abstract class PoraShadowsDark {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  static List<BoxShadow> warm = [
    BoxShadow(
      color: PoraColorsDark.primary.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
