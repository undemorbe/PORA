import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Финальный шаг — «дальше сами». Никаких новых жестов: приветственная
/// рука, галочка и лёгкие «искры» для настроения. Иллюстрация не учит,
/// а закрывает: «мы всё сказали».
class OutroStep extends StatelessWidget {
  const OutroStep({super.key});

  @override
  Widget build(BuildContext context) {
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 3200),
        builder: (context, t) => Stack(
          alignment: Alignment.center,
          children: [
            _Sparkles(t: t),
            _WavingHand(t: t),
            const Positioned(bottom: 12, child: _CheckBadge()),
          ],
        ),
      ),
    );
  }
}

/// Рука с волной — 3 качка вправо-влево на цикле.
class _WavingHand extends StatelessWidget {
  const _WavingHand({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    // Волна с амплитудой 0.35 rad, 2 полных периода за цикл.
    final wave = 0.35 * math.sin(t * math.pi * 4);
    return Transform.rotate(
      angle: wave,
      alignment: Alignment.bottomCenter,
      child: const Icon(
        PhosphorIconsFill.handWaving,
        size: 88,
        color: PoraColors.primary,
      ),
    );
  }
}

/// Три «искры» вокруг руки — статичные точки-эмиттеры, каждая с
/// своим фазовым сдвигом. Даёт ощущение «завершил».
class _Sparkles extends StatelessWidget {
  const _Sparkles({required this.t});
  final double t;

  static const _positions = <Offset>[
    Offset(-70, -20),
    Offset(60, -40),
    Offset(70, 30),
    Offset(-60, 40),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < _positions.length; i++)
          _Sparkle(offset: _positions[i], phase: (t + i * 0.25) % 1),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.offset, required this.phase});
  final Offset offset;
  final double phase;

  @override
  Widget build(BuildContext context) {
    // Двугорбая парабола → плавное появление-исчезновение.
    final v = 4 * phase * (1 - phase);
    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.4 + v * 0.8,
          child: const Icon(
            PhosphorIconsFill.sparkle,
            size: 22,
            color: PoraColors.primary,
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: PoraColors.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(PhosphorIconsBold.check, color: Colors.white, size: 26),
    );
  }
}
