import 'package:flutter/material.dart';
import 'package:pora/app/features/home/domain/entity/list_item.dart';
import 'package:pora/app/features/home/presentation/widgets/list_item_tile.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Секция списка: заголовок отдела + карточка со строками товаров.
class SectionGroup extends StatelessWidget {
  const SectionGroup({super.key, required this.section, required this.colorOf});

  final ListSection section;
  final Color Function(String initial) colorOf;

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
      tiles.add(ListItemTile(item: item, addedByColor: colorOf(item.addedBy)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(section.title),
        PoraCard(
          padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xs),
          child: Column(children: tiles),
        ),
        const SizedBox(height: PoraSpacing.lg),
      ],
    );
  }
}
