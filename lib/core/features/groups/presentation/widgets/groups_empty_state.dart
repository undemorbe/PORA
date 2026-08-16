import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Empty state: пружинящая корзина + плюс, текст, кнопка создать.
class GroupsEmptyState extends StatefulWidget {
  const GroupsEmptyState({super.key, required this.onCreate});
  final VoidCallback onCreate;

  @override
  State<GroupsEmptyState> createState() => _GroupsEmptyStateState();
}

class _GroupsEmptyStateState extends State<GroupsEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

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
                // Мягкое покачивание + пульс масштаба.
                final t = _c.value;
                final rot = math.sin(t * math.pi * 2) * 0.06;
                final scale = 1 + math.sin(t * math.pi * 2) * 0.04;
                return Transform.rotate(
                  angle: rot,
                  child: Transform.scale(
                    scale: scale,
                    child: _EmptyBadge(t: t),
                  ),
                );
              },
            ),
            const SizedBox(height: PoraSpacing.lg),
            Text(
              'Списков у вас пока нет',
              style: PoraText.itemTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Может стоит создать новый?',
              style: PoraText.small.copyWith(color: c.textSubtle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PoraSpacing.lg),
            PressScale(
              onTap: widget.onCreate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: PoraColors.primary,
                  borderRadius: PoraRadii.pill,
                  boxShadow: [
                    BoxShadow(
                      color: PoraColors.primary.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PhosphorIconsBold.plus,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Создать список',
                      style: PoraText.itemTitle.copyWith(
                        color: Colors.white,
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

class _EmptyBadge extends StatelessWidget {
  const _EmptyBadge({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PoraColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        PhosphorIconsFill.shoppingCart,
        size: 60,
        color: PoraColors.primary,
      ),
    );
  }
}
