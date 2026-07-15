import 'package:flutter/material.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_item_tile.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Секция списка: заголовок отдела + карточка со строками товаров.
class SectionGroup extends StatelessWidget {
  const SectionGroup({
    super.key,
    required this.section,
    this.onProductTap,
    this.onListTap,
  });

  final ListSectionEntity section;
  final void Function(ProductEntity product)? onProductTap;
  final void Function(ListSectionEntity listid)? onListTap;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    for (var i = 0; i < section.items.length; i++) {
      if (i > 0) {
        tiles.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: PoraSpacing.lg,
            endIndent: PoraSpacing.lg,
            color: Theme.of(context).dividerColor,
          ),
        );
      }
      final item = section.items[i];
      tiles.add(
        ListItemTile(
          item: item,
          addedBy: item.addedBy,
          onTap: onProductTap == null
              ? () => onListTap!(section)
              : () => onProductTap!(item),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(section.name),
        PoraCard(
          padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xs),
          child: Column(children: tiles),
        ),
        const SizedBox(height: PoraSpacing.lg),
      ],
    );
  }
}
