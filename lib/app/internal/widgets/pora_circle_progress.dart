import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Фирменный круговой индикатор Pora.
///
/// «Живой» стиль: переливающийся градиентный сегмент с закруглённым
/// концом, мягкое свечение по контуру и светящаяся «голова-комета»
/// на кончике дуги.
///
/// Два режима:
///  • [value] == null → бесконечное вращение (загрузка);
///  • [value] в 0..1  → детерминированный прогресс с плавным
///    доводом до нового значения.
class PoraCircleProgress extends StatefulWidget {
  const PoraCircleProgress({
    super.key,
    this.value,
    this.size = 55,
    this.strokeWidth = 7,
    this.gradientColors,
    this.trackColor,
    this.showPercentage = false,
    this.child,
  }) : assert(value == null || (value >= 0 && value <= 1));

  /// null → бесконечная анимация; иначе прогресс 0..1.
  final double? value;
  final double size;
  final double strokeWidth;

  /// Цвета градиентного сегмента (по кругу). По умолчанию тёплый свирл.
  final List<Color>? gradientColors;
  final Color? trackColor;

  /// Показать «NN%» в центре (только для детерминированного режима).
  final bool showPercentage;

  /// Произвольный центр (иконка/текст). Приоритетнее [showPercentage].
  final Widget? child;

  @override
  State<PoraCircleProgress> createState() => _PoraCircleProgressState();
}

class _PoraCircleProgressState extends State<PoraCircleProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  bool get _indeterminate => widget.value == null;

  @override
  void initState() {
    super.initState();
    // Контроллер всегда крутится: в indeterminate — как спиннер,
    // в determinate — как мягкое мерцание градиента/пульс головы.
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _indeterminate ? 1400 : 3200),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant PoraCircleProgress old) {
    super.didUpdateWidget(old);
    if (_indeterminate != (old.value == null)) {
      _c.duration = Duration(milliseconds: _indeterminate ? 1400 : 3200);
      _c
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<Color> get _gradient =>
      widget.gradientColors ??
      const [
        PoraColors.primary,
        PoraColors.primaryDark,
        PoraColors.sage,
        PoraColors.primary,
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TweenAnimationBuilder<double>(
        // Плавный доезд прогресса при смене value.
        tween: Tween(begin: 0, end: widget.value ?? 0),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              return CustomPaint(
                painter: _PoraCircleProgressPainter(
                  progress: _indeterminate ? null : animatedValue,
                  spin: _c.value,
                  strokeWidth: widget.strokeWidth,
                  gradient: _gradient,
                  trackColor:
                      widget.trackColor ??
                      PoraColors.primary.withValues(alpha: 0.12),
                ),
                child: Center(child: _center(animatedValue)),
              );
            },
          );
        },
      ),
    );
  }

  Widget? _center(double animatedValue) {
    if (widget.child != null) return widget.child;
    if (widget.showPercentage && !_indeterminate) {
      return Text(
        '${(animatedValue * 100).round()}%',
        style: PoraText.heading.copyWith(
          fontSize: widget.size * 0.24,
          color: PoraColors.ink,
        ),
      );
    }
    return null;
  }
}

class _PoraCircleProgressPainter extends CustomPainter {
  _PoraCircleProgressPainter({
    required this.progress,
    required this.spin,
    required this.strokeWidth,
    required this.gradient,
    required this.trackColor,
  });

  /// null → indeterminate.
  final double? progress;
  final double spin; // 0..1 — фаза вращения/мерцания
  final double strokeWidth;
  final List<Color> gradient;
  final Color trackColor;

  static const _twoPi = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Трек — тонкая подложка.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    // Геометрия дуги.
    final double startAngle;
    final double sweep;
    if (progress == null) {
      // Бесконечный режим: вращаем и «дышим» длиной дуги.
      final breathe = 0.55 + 0.30 * math.sin(spin * _twoPi);
      sweep = _twoPi * breathe;
      startAngle = spin * _twoPi * 1.6 - math.pi / 2;
    } else {
      sweep = _twoPi * progress!.clamp(0.0, 1.0);
      startAngle = -math.pi / 2;
    }

    // Градиент вращается вместе с фазой — эффект перелива.
    final shader = SweepGradient(
      colors: gradient,
      startAngle: 0,
      endAngle: _twoPi,
      transform: GradientRotation(startAngle + spin * _twoPi * 0.2),
    ).createShader(rect);

    // 2. Свечение — размытая копия дуги под основным штрихом.
    if (sweep > 0) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth * 1.7
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(rect, startAngle, sweep, false, glow);

      // 3. Основная дуга.
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..shader = shader;
      canvas.drawArc(rect, startAngle, sweep, false, arc);

      // 4. Светящаяся «голова-комета» на кончике.
      final headAngle = startAngle + sweep;
      final head = Offset(
        center.dx + radius * math.cos(headAngle),
        center.dy + radius * math.sin(headAngle),
      );
      final pulse = 0.85 + 0.15 * math.sin(spin * _twoPi * 2);
      canvas.drawCircle(
        head,
        strokeWidth * 0.55 * pulse,
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        head,
        strokeWidth * 0.42 * pulse,
        Paint()..color = gradient.last,
      );
    }
  }

  @override
  bool shouldRepaint(_PoraCircleProgressPainter old) =>
      old.progress != progress ||
      old.spin != spin ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
