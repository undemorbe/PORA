import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Error state: качающийся warning-значок, текст, кнопка «Повторить».
class GroupsErrorState extends StatefulWidget {
  const GroupsErrorState({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  State<GroupsErrorState> createState() => _GroupsErrorStateState();
}

class _GroupsErrorStateState extends State<GroupsErrorState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PoraSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                // Мягкий wobble.
                final rot = math.sin(_c.value * math.pi) * 0.08;
                return Transform.rotate(
                  angle: rot,
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PoraColors.danger.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIconsFill.warning,
                      size: 56,
                      color: PoraColors.danger,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: PoraSpacing.lg),
            Text(
              'Произошла ошибка',
              style: PoraText.itemTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.message ??
                  'Не удалось загрузить списки. Попробуйте снова.',
              style: PoraText.small.copyWith(color: c.textSubtle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PoraSpacing.lg),
            PressScale(
              onTap: widget.onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: PoraRadii.pill,
                  border: Border.all(color: c.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PhosphorIconsRegular.arrowClockwise,
                      color: PoraColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Повторить',
                      style: PoraText.itemTitle.copyWith(
                        color: PoraColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
