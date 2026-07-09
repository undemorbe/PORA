import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
import 'package:pora/app/features/families/presentation/widgets/member_color.dart';
import 'package:pora/app/features/families/presentation/widgets/product_preview.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Карточка семьи: аватары участников (инициалы из members), название,
/// метка «Текущая» и превью срочных продуктов. Тап открывает семью.
class FamilyCard extends StatelessWidget {
  const FamilyCard({super.key, required this.family, this.onTap});

  final FamilyEntity family;
  final VoidCallback? onTap;

  static const double _avatar = 32;
  static const double _overlap = 20;

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.surface;
    final members = family.members;
    final avatarsWidth = members.isEmpty
        ? 0.0
        : _avatar + (members.length - 1) * _overlap;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PoraCard(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.lg,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: avatarsWidth,
              height: _avatar,
              child: Stack(
                children: [
                  for (var i = 0; i < members.length; i++)
                    Positioned(
                      left: i * _overlap,
                      child: PoraAvatar(
                        initial: memberInitial(members[i]),
                        color: memberColor(members[i], i),
                        size: _avatar,
                        ring: ring,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: PoraSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          family.name,
                          style: PoraText.button,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (family.isCurrent) ...[
                        const SizedBox(width: PoraSpacing.sm),
                        PoraPill(label: context.l10n.familiesCurrent),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProductPreview(products: family.highPriorityProducts),
                ],
              ),
            ),
            const SizedBox(width: PoraSpacing.sm),
            const PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              size: 20,
              color: Color(0xFFC9BEAE),
            ),
          ],
        ),
      ),
    );
  }
}
