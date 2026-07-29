import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_finger.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_row_tile.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Шаг 3. Добавление продукта: тап FAB → новая строка проявляется снизу.
class AddStep extends StatelessWidget {
  const AddStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 2400),
        builder: (context, t) {
          final pressed = t > 0.30 && t < 0.50;
          final appearRaw = t < 0.5
              ? 0.0
              : Curves.easeOutBack.transform(((t - 0.5) / 0.4).clamp(0.0, 1.0));
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: TutorialRowTile(title: l.tutorialSampleMilk),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 62,
                child: TutorialRowTile(title: l.tutorialSampleBread),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 120,
                child: _NewItem(
                  title: l.tutorialSampleAvocado,
                  appearRaw: appearRaw,
                ),
              ),
              Positioned(right: 8, bottom: 8, child: _AddFab(pressed: pressed)),
              if (pressed)
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: TutorialFinger(position: Offset(0, 0), scale: 1.2),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NewItem extends StatelessWidget {
  const _NewItem({required this.title, required this.appearRaw});
  final String title;
  final double appearRaw;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: appearRaw.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 0.7 + 0.3 * appearRaw,
        child: TutorialRowTile(title: title),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.pressed});
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: pressed ? 0.9 : 1.0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: PoraColors.primary,
          borderRadius: PoraRadii.pill,
          boxShadow: [
            BoxShadow(
              color: PoraColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          PhosphorIconsBold.plus,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
