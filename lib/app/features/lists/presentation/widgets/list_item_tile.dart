import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_checkbox.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Одна строка товара: чекбокс · название/кол-во · (срочно) · аватар «от кого».
class ListItemTile extends StatelessWidget {
  const ListItemTile({
    super.key,
    required this.item,
    required this.addedBy,
    this.onTap,
  });

  final ProductEntity item;
  final MemberEntity addedBy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nameStyle = item.checked
        ? PoraText.itemTitle.copyWith(
            color: PoraColors.textMuted,
            decoration: TextDecoration.lineThrough,
          )
        : PoraText.itemTitle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.lg,
          vertical: PoraSpacing.md,
        ),
        child: Row(
          children: [
            //! add check box handle
            PoraCheckbox(checked: item.checked),
            const SizedBox(width: PoraSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: nameStyle),
                  if (item.quantity != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: PoraSpacing.xxs),
                      child: Text(
                        item.quantity.toString(),
                        style: PoraText.small,
                      ),
                    ),
                ],
              ),
            ),
            if (item.urgent) ...[
              PoraPill(
                label: context.l10n.listUrgent,
                icon: PhosphorIconsRegular.clock,
                background: PoraColors.primaryTintStrong,
              ),
              const SizedBox(width: PoraSpacing.md),
            ],
            PoraAvatar(
              initial: addedBy.name[0],
              color: memberColor(addedBy, 0),
              imageUrl: addedBy.imageUrl,
            ),
          ],
        ),
      ),
    );
  }
}
