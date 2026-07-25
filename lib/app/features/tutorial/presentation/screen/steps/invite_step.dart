import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_curves.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_finger.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_row_tile.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_slidable_panel.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Шаг 1. Инвайт: свайп группы вправо → панель «Invite» проявляется слева.
class InviteStep extends StatelessWidget {
  const InviteStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 2600),
        builder: (context, t) {
          final swipe = swipeCycle(t, 96);
          final fingerX = 8.0 + swipe;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 0,
                top: 100,
                child: TutorialSlidablePanel(
                  width: swipe,
                  color: PoraColors.primary,
                  icon: PhosphorIconsRegular.userPlus,
                  side: Alignment.centerLeft,
                  label: l.groupConnect,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 100,
                child: _GroupTile(
                  title: l.tutorialSampleGroupFamily,
                  offsetX: swipe,
                ),
              ),
              TutorialFinger(position: Offset(fingerX, 108)),
            ],
          );
        },
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.title, required this.offsetX});
  final String title;
  final double offsetX;

  @override
  Widget build(BuildContext context) {
    return TutorialRowTile(
      title: title,
      offsetX: offsetX,
      leading: const Icon(
        PhosphorIconsFill.usersThree,
        size: 22,
        color: PoraColors.primary,
      ),
      trailing: Text(
        '4',
        style: PoraText.small.copyWith(color: context.colors.textSubtle),
      ),
    );
  }
}
