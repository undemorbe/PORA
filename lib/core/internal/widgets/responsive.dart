import 'package:flutter/widgets.dart';

/// Брейкпоинты ширины (логические пиксели). Телефон / планшет / десктоп.
abstract class Breakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

enum ScreenClass { phone, tablet, desktop }

ScreenClass screenClassOf(double width) {
  if (width < Breakpoints.phone) return ScreenClass.phone;
  if (width < Breakpoints.tablet) return ScreenClass.tablet;
  return ScreenClass.desktop;
}

/// Сколько колонок в grid при данной ширине.
int gridColumnsFor(double width) {
  if (width < Breakpoints.phone) return 1;
  if (width < Breakpoints.tablet) return 2;
  if (width < Breakpoints.desktop) return 3;
  return 4;
}

/// Максимальная ширина контента — на больших экранах центрируем, чтобы строки
/// не растягивались на всю ширину планшета/десктопа.
double contentMaxWidthFor(double width) {
  if (width < Breakpoints.tablet) return double.infinity;
  if (width < Breakpoints.desktop) return 760;
  return 960;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  ScreenClass get screenClass => screenClassOf(screenWidth);
  bool get isPhone => screenClass == ScreenClass.phone;
  bool get isTabletOrWider => screenClass != ScreenClass.phone;
}

/// Центрирует и ограничивает ширину контента на больших экранах.
class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxWidth = contentMaxWidthFor(context.screenWidth);
    if (!maxWidth.isFinite) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
