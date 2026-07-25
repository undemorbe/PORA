import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Виртуальный «палец пользователя» — кружок с брендовой каймой.
/// Позиционируется внутри `Stack` через [Positioned] (Left/top от [position]).
/// Не блокирует хиты.
class TutorialFinger extends StatelessWidget {
  const TutorialFinger({super.key, required this.position, this.scale = 1});

  final Offset position;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PoraColors.primary.withValues(alpha: 0.22),
              border: Border.all(color: PoraColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
