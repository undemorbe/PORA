import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';

/// Уникальный loading-стейт для groups: 3 shimmer-карточки с волной блика.
class GroupsLoading extends StatefulWidget {
  const GroupsLoading({super.key, this.itemCount = 3});
  final int itemCount;

  @override
  State<GroupsLoading> createState() => _GroupsLoadingState();
}

class _GroupsLoadingState extends State<GroupsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.xxs),
          child: Column(
            children: [
              for (var i = 0; i < widget.itemCount; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: PoraSpacing.md),
                  child: _ShimmerCard(t: (_c.value + i * 0.15) % 1),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: PoraRadii.card,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: PoraRadii.card,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(PoraSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: PoraSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bar(width: 140, color: c.surfaceAlt),
                        const SizedBox(height: 8),
                        _Bar(width: 90, color: c.surfaceAlt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Волна-блик, edge-to-edge, движется слева направо.
            Positioned.fill(
              child: FractionallySizedBox(
                widthFactor: 0.4,
                alignment: Alignment(-1 + 2.4 * t, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        c.surface.withValues(alpha: 0),
                        c.surfaceAlt.withValues(alpha: 0.7),
                        c.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.color});
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
