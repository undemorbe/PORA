import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Скруглённая карточка-поверхность с мягкой тенью.
/// Используется как контейнер секций списка, карточек предсказаний и т.п.
class PoraCard extends StatelessWidget {
  const PoraCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = PoraRadii.card,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: radius,
        boxShadow: PoraShadows.card,
      ),
      child: child,
    );
  }
}
