import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/home/domain/entity/list_item.dart';
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
    required this.addedByColor,
  });

  final ListItem item;
  final Color addedByColor;

  @override
  Widget build(BuildContext context) {
    final nameStyle = item.checked
        ? PoraText.itemTitle.copyWith(
            color: PoraColors.textMuted,
            decoration: TextDecoration.lineThrough,
          )
        : PoraText.itemTitle;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: PoraSpacing.md,
      ),
      child: Row(
        children: [
          PoraCheckbox(checked: item.checked),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: nameStyle),
                if (item.qty != null)
                  Padding(
                    padding: const EdgeInsets.only(top: PoraSpacing.xxs),
                    child: Text(item.qty!, style: PoraText.small),
                  ),
              ],
            ),
          ),
          if (item.urgent) ...[
            const PoraPill(
              label: 'Срочно',
              icon: PhosphorIconsRegular.clock,
              background: PoraColors.primaryTintStrong,
            ),
            const SizedBox(width: PoraSpacing.md),
          ],
          PoraAvatar(initial: item.addedBy, color: addedByColor),
        ],
      ),
    );
  }
}
