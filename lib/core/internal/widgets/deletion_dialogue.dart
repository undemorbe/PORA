import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/additional_constants.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';

class DeletionDialogue extends StatelessWidget {
  const DeletionDialogue({super.key, required this.onDelete, this.title});

  final VoidCallback onDelete;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(PoraSpacing.lg),
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 0.0,
                left: 7,
                bottom: 35,
                right: 7,
              ),
              child: Text(
                title ?? context.l10n.briefDeletionTitle,
                style: PoraText.title.copyWith(color: PoraColors.danger),
                textAlign: TextAlign.center,
              ),
            ),
            PoraPrimaryButton(
              icon: PhosphorIcons.trash,
              onPressed: () {
                onDelete();

                context.router.pop();
              },
              label: context.l10n.confirmations,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PoraOutlineButton(
                onPressed: () {
                  context.router.pop();
                },
                label: context.l10n.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
