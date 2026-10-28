import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

/// iOS-эксклюзивная «стеклянная» обёртка поверх liquid_glass_easy.
///
/// На iOS (Impeller) оборачивает [child] в [LiquidGlassLens] — реальное
/// преломляющее стекло, работает standalone без фонового захвата. На других
/// платформах возвращает [fallback] (или сам [child]), чтобы не тянуть
/// iOS-эффект туда, где он не нативен.
///
/// Использовать на «логичных» местах: круглые кнопки, пилюли, плавающие панели.
/// Не оборачивать крупные скроллящиеся списки (дорого) и не ставить поверх
/// уже стеклянных компонентов (двойное стекло).
class PoraGlass extends StatelessWidget {
  const PoraGlass({
    super.key,
    required this.child,
    this.cornerRadius = 20,
    this.fallback,
    this.enabled = true,
  });

  final Widget child;
  final double cornerRadius;

  /// Чем заменить стекло вне iOS. По умолчанию — сам [child].
  final Widget? fallback;

  /// Позволяет отключить стекло точечно (например, при reduce-motion).
  final bool enabled;

  bool get _useGlass => enabled && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (!_useGlass) return fallback ?? child;
    return LiquidGlassLens(
      style: LiquidGlassStyle(
        shape: LiquidGlassShape.continuousRoundedRectangle(
          cornerRadius: cornerRadius,
          borderWidth: 1.0,
          lightIntensity: 1.1,
          lightDirection: 39,
        ),
      ),
      child: child,
    );
  }
}
