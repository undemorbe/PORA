import 'package:flutter/material.dart';

/// Текст с плавно рисующейся линией зачёркивания.
///
/// - `struck: true` → линия «прорастает» слева направо (0 → 1) за [duration].
/// - `struck: false` → линия схлопывается обратно.
/// - Цвет и толщина линии — [lineColor], [lineThickness].
/// - Параллельно fade text color: `activeColor` ↔ `mutedColor`.
class StrikeThroughText extends StatelessWidget {
  const StrikeThroughText({
    super.key,
    required this.text,
    required this.style,
    required this.struck,
    required this.activeColor,
    required this.mutedColor,
    this.duration = const Duration(milliseconds: 320),
    this.curve = Curves.easeOutCubic,
    this.lineThickness = 1.5,
  });

  final String text;
  final TextStyle style;
  final bool struck;
  final Color activeColor;
  final Color mutedColor;
  final Duration duration;
  final Curve curve;
  final double lineThickness;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // `end` меняется при struck ↔ TweenAnimationBuilder auto-interpolate
      // от прошлого значения к новому.
      tween: Tween<double>(begin: 0.0, end: struck ? 1.0 : 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, _) {
        final color = Color.lerp(activeColor, mutedColor, value)!;
        final effective = style.copyWith(color: color);
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Text(text, style: effective),
            Positioned.fill(
              child: CustomPaint(
                painter: _StrikePainter(
                  fraction: value,
                  color: color,
                  thickness: lineThickness,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StrikePainter extends CustomPainter {
  _StrikePainter({
    required this.fraction,
    required this.color,
    required this.thickness,
  });

  final double fraction;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0) return;
    final y = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, y), Offset(size.width * fraction, y), paint);
  }

  @override
  bool shouldRepaint(covariant _StrikePainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.thickness != thickness;
}
