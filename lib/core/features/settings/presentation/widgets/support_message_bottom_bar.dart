import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_card.dart';

class SupportMessageBottomSheet extends StatelessWidget {
  const SupportMessageBottomSheet({
    super.key,
    required this.messageController,
    required this.onTap,
  });

  final TextEditingController messageController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mqs = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PoraCard(
        padding: .all(8),
        child: Column(
          mainAxisSize: .min,
          children: [
            Divider(
              endIndent: mqs.width * 0.39,
              indent: mqs.width * 0.39,
              thickness: 2,
            ),
            Center(
              child: Text(
                context.l10n.supportMessageBottomSheetTopDescription,
                style: PoraText.navTitle.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: .center,
              ),
            ),
            const SizedBox(height: PoraSpacing.screen),
            TextField(
              maxLines: 10,
              minLines: 3,
              controller: messageController,
              decoration: InputDecoration(
                hintText: context.l10n.supportMessage,
                suffixIcon: IconButton(
                  icon: Icon(PhosphorIcons.paperPlaneTilt),
                  onPressed: onTap,
                ),
              ),
            ),
            const SizedBox(height: PoraSpacing.screen),
            PoraPrimaryButton(label: context.l10n.notifySend, onPressed: onTap),
            const SizedBox(height: PoraSpacing.xxs),
            PoraPrimaryButton(
              label: context.l10n.cancel,
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: PoraSpacing.xxs),
            Text(
              context.l10n.supportMessageBottomSheetUnderButtonText,
              style: PoraText.micro.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
