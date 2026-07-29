import 'package:flutter/animation.dart';

/// Единый паттерн свайпа: 0 → hold(amp) → 0.
/// easeOut на разгон (0..0.4), удержание (0.4..0.75), easeIn на возврат (0.75..1).
double swipeCycle(double t, double amp) {
  if (t < 0.4) return Curves.easeOut.transform(t / 0.4) * amp;
  if (t < 0.75) return amp;
  return amp * (1 - Curves.easeIn.transform((t - 0.75) / 0.25));
}

/// Линейное появление в интервале `[start, end]`, clamp'нутое в `[0, 1]`.
double fadeIn(double t, double start, double end) {
  if (t < start) return 0;
  if (t > end) return 1;
  return ((t - start) / (end - start)).clamp(0.0, 1.0);
}

/// EaseIn-траектория по Y между `from` → `to` на окне `[start, end]`.
double dropY(double t, double start, double end, double from, double to) {
  final p = Curves.easeIn.transform(fadeIn(t, start, end));
  return from + (to - from) * p;
}
