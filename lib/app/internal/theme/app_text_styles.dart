
// -----------------------------------------------------------------------------
//  TYPOGRAPHY  (Inter)
//  Веса: Regular 400 · Medium 500 · SemiBold 600 · Bold 700 · ExtraBold 800
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';


const String kPoraFontFamily = 'Inter';


abstract class PoraText {
  static const TextStyle _base = TextStyle(
    fontFamily: kPoraFontFamily,
    color: PoraColors.ink,
    height: 1.25,
  );

  /// 28 / ExtraBold — крупные заголовки онбординга
  static final TextStyle display =
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15);

  /// 24 / ExtraBold — заголовок экрана
  static final TextStyle title =
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2);

  /// 20 / Bold — подзаголовок секции
  static final TextStyle heading =
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700);

  /// 18 / SemiBold — заголовок в навбаре
  static final TextStyle navTitle =
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  /// 16 / SemiBold — кнопки, акцентные строки
  static final TextStyle button =
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  /// 16 / Medium — крупный body
  static final TextStyle bodyLarge =
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w500);

  /// 15 / Medium — названия товаров в строках
  static final TextStyle itemTitle =
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w500);

  /// 15 / Regular — обычный текст
  static final TextStyle body = _base.copyWith(fontSize: 15);

  /// 15 / Regular muted — подзаголовки
  static final TextStyle subtitle =
      _base.copyWith(fontSize: 15, color: PoraColors.textMuted, height: 1.4);

  /// 13 / Regular muted — подписи, мета
  static final TextStyle caption =
      _base.copyWith(fontSize: 13, color: PoraColors.textSubtle, height: 1.4);

  /// 12 / Regular muted — мелкая мета (кол-во, частота)
  static final TextStyle small =
      _base.copyWith(fontSize: 12, color: PoraColors.textSubtle);

  /// 12 / SemiBold uppercase + трекинг — заголовки-разделители секций
  static final TextStyle overline = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: PoraColors.textSubtle,
    letterSpacing: 0.6,
  );

  /// 11 / SemiBold — пилюли и подписи табов
  static final TextStyle micro =
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w600);

  /// 22 / ExtraBold + трекинг — код приглашения
  static final TextStyle code = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );
}
