import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_chat_sheet.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_hero_tags.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Компактный CTA «Спросить PORA» — вставляется на групповой экран.
/// Sparkle-аватар обёрнут в Hero → плавно морфит в header чат-листа.
class PoraCtaCard extends StatelessWidget {
  const PoraCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return PressScale(
      onTap: () =>
          openPoraChatSheet(context, heroTag: PoraHeroTags.poraAvatarCta),
      child: Container(
        padding: const EdgeInsets.all(PoraSpacing.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: PoraRadii.card,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Row(
          children: [
            Hero(
              tag: PoraHeroTags.poraAvatarCta,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PoraColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PoraColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    PhosphorIconsFill.sparkle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: PoraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.aiCtaTitle,
                    style: PoraText.itemTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l.aiCtaSubtitle,
                    style: PoraText.small.copyWith(color: c.textSubtle),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              size: 18,
              color: PoraColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
