import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

// -----------------------------------------------------------------------------
//  SPACING  (8pt-сетка, padding экрана = 24)
// -----------------------------------------------------------------------------

abstract class PoraSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double screen = 24; // горизонтальный отступ экрана
}

// -----------------------------------------------------------------------------
//  RADIi
// -----------------------------------------------------------------------------
abstract class PoraRadii {
  static const Radius _sm = Radius.circular(8);
  static const Radius _md = Radius.circular(11);
  static const Radius _input = Radius.circular(14);
  static const Radius _button = Radius.circular(16);
  static const Radius _card = Radius.circular(18);
  static const Radius _tile = Radius.circular(24);

  static const BorderRadius sm = BorderRadius.all(_sm); // чекбокс
  static const BorderRadius md = BorderRadius.all(_md); // мелкие пилюли-кнопки
  static const BorderRadius input = BorderRadius.all(_input); // поля, мелкие чипы
  static const BorderRadius button = BorderRadius.all(_button); // кнопки
  static const BorderRadius card = BorderRadius.all(_card); // карточки
  static const BorderRadius tile = BorderRadius.all(_tile); // плитки-иллюстрации
  static const BorderRadius pill =
      BorderRadius.all(Radius.circular(999)); // чипы/пилюли/FAB
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

// -----------------------------------------------------------------------------
//  SIZES  (ключевые размеры компонентов)
// -----------------------------------------------------------------------------
abstract class PoraSizes {
  static const double buttonHeight = 54;
  static const double fieldHeight = 56;
  static const double chipHeight = 36;
  static const double toggleWidth = 48;
  static const double toggleHeight = 28;
  static const double toggleKnob = 22;
  static const double checkbox = 24;
  static const double tabBarHeight = 86;
  static const double statusBarHeight = 50;

  // Аватары
  static const double avatarXs = 24; // метка «от кого» в строке
  static const double avatarSm = 32; // список участников
  static const double avatarMd = 46; // карточка предсказания
  static const double avatarLg = 56; // профиль
  static const double avatarXl = 64; // приглашение партнёра
}
