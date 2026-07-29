import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_finger.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_row_tile.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_slidable_panel.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Шаг 6. Удаление: свайп tile влево → панель Trash → tile улетает за экран.
class DeleteStep extends StatelessWidget {
  const DeleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: LayoutBuilder(
        builder: (context, bc) => TutorialTicker(
          duration: const Duration(milliseconds: 2800),
          builder: (context, t) {
            final phase = _DeletePhase.from(t, bc.maxWidth);
            final fingerX = (bc.maxWidth - 42) + phase.baseOffset;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: 0,
                  top: 100,
                  child: TutorialSlidablePanel(
                    width: phase.panelWidth,
                    color: PoraColors.danger,
                    icon: PhosphorIconsRegular.trash,
                    side: Alignment.centerRight,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 100,
                  child: TutorialRowTile(
                    title: l.tutorialSampleCola,
                    offsetX: phase.baseOffset,
                    opacity: phase.opacity,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 42,
                  child: Opacity(
                    opacity: 0.55,
                    child: TutorialRowTile(title: l.tutorialSampleBread),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 158,
                  child: Opacity(
                    opacity: 0.55,
                    child: TutorialRowTile(title: l.tutorialSampleCoffee),
                  ),
                ),
                if (phase.opacity > 0.15)
                  TutorialFinger(position: Offset(fingerX, 108)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Значения анимации удаления, разложенные по фазам:
///   0..0.4  — свайп до `-96`
///   0.4..0.7 — hold
///   0.7..0.85 — «улёт» tile за экран + fade
///   0.85..1 — reset (мгновенный)
class _DeletePhase {
  const _DeletePhase({
    required this.baseOffset,
    required this.opacity,
    required this.panelWidth,
  });

  final double baseOffset;
  final double opacity;
  final double panelWidth;

  factory _DeletePhase.from(double t, double maxWidth) {
    final base = t < 0.4
        ? -Curves.easeOut.transform(t / 0.4) * 96
        : t < 0.7
        ? -96.0
        : t < 0.85
        ? -96 - maxWidth * Curves.easeIn.transform((t - 0.7) / 0.15)
        : 0.0;
    final opacity = t < 0.7
        ? 1.0
        : t < 0.85
        ? 1 - (t - 0.7) / 0.15
        : 0.0;
    final panelWidth = (base < 0 ? -base : 0.0).clamp(0.0, maxWidth);
    return _DeletePhase(
      baseOffset: base,
      opacity: opacity,
      panelWidth: panelWidth,
    );
  }
}
