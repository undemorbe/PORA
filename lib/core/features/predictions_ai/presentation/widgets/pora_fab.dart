import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_hero_tags.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// FAB «Спросить PORA». Sparkle-иконка + мягкий пульс тени + press-scale.
/// Обёрнут в Hero(`poraAvatar`) для морфа в header чат-листа.
class PoraFab extends StatefulWidget {
  const PoraFab({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<PoraFab> createState() => _PoraFabState();
}

class _PoraFabState extends State<PoraFab> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        // sin-волна: тень пульсирует от 14 до 26 blur.
        final t = (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
        final blur = 18 + 10 * t;
        return PressScale(
          onTap: widget.onTap,
          child: Hero(
            tag: PoraHeroTags.poraAvatarFab,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PoraColors.primary.withValues(alpha: 0.35),
                      blurRadius: blur,
                      offset: const Offset(0, 10),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(
                  PhosphorIconsFill.sparkle,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
