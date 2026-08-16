import 'package:flutter/material.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_finger.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_row_tile.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';

/// Шаг 4. Правка/отметить: палец подкатывается, тапает чекбокс — строка становится куплена.
class EditStep extends StatelessWidget {
  const EditStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 2200),
        builder: (context, t) {
          final checked = t > 0.45;
          final fingerScale = t < 0.4
              ? 1 + 0.2 * (0.4 - t) / 0.4
              : t < 0.55
              ? 0.85
              : 1.0;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                child: TutorialRowTile(
                  title: l.tutorialSampleMilkQty,
                  checked: checked,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 98,
                child: TutorialRowTile(title: l.tutorialSampleBread),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 156,
                child: TutorialRowTile(title: l.tutorialSampleCoffee),
              ),
              TutorialFinger(position: const Offset(7, 49), scale: fingerScale),
            ],
          );
        },
      ),
    );
  }
}
