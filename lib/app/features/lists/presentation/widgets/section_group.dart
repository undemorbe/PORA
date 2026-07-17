import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/item_detail/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_item_tile.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Секция списка: заголовок отдела + карточка со строками товаров.
/// Каждая строка — Slidable вправо для удаления (свайп + confirm-dialog
/// с тумблером «не спрашивать»).
class SectionGroup extends StatelessWidget {
  const SectionGroup({
    super.key,
    required this.section,
    this.onProductTap,
    this.onListTap,
    this.onDeleteConfirmed,
    this.onNotify,
    this.onToggleBought,
  });

  final ListSectionEntity section;
  final void Function(ProductEntity product)? onProductTap;
  final void Function(ListSectionEntity listid)? onListTap;

  /// Вызывается после подтверждения удаления. Actual DELETE запрос —
  /// снаружи (обычно в ListStore).
  final void Function(ProductEntity product)? onDeleteConfirmed;

  /// Тап по slidable-action «Уведомить».
  final void Function(ProductEntity product)? onNotify;

  /// Тап по чекбоксу (PATCH /items/{iid}/bought).
  final void Function(ProductEntity product)? onToggleBought;

  @override
  Widget build(BuildContext context) {
    final n = section.items.length;
    final tiles = <Widget>[];
    for (var i = 0; i < n; i++) {
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
      final isFirst = i == 0;
      final isLast = i == n - 1;
      tiles.add(_tile(context, item, isFirst: isFirst, isLast: isLast));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(section.name),
        PoraCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: PoraRadii.card,
            child: Column(children: tiles),
          ),
        ),
        const SizedBox(height: PoraSpacing.lg),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    ProductEntity item, {
    required bool isFirst,
    required bool isLast,
  }) {
    final tile = ListItemTile(
      item: item,
      addedBy: item.addedBy,
      onTap: onProductTap == null
          ? () => onListTap!(section)
          : () => onProductTap!(item),
      onCheckboxTap: onToggleBought == null
          ? null
          : () => onToggleBought!(item),
    );

    // Slidable только на concrete-list режим (когда есть product tap
    // и передан обработчик).
    if (onProductTap == null || onDeleteConfirmed == null) return tile;

    return Slidable(
      key: ValueKey('slidable_${item.id}'),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.56,
        children: [
          if (onNotify != null)
            SlidableAction(
              onPressed: (_) => onNotify!(item),
              backgroundColor: PoraColors.primary,
              foregroundColor: PoraColors.inkInverse,
              icon: PhosphorIconsFill.bell,
              label: context.l10n.notify,
            ),
          SlidableAction(
            onPressed: (ctx) async {
              final ok = await confirmDeleteItem(ctx);
              if (ok) onDeleteConfirmed!(item);
            },
            backgroundColor: PoraColors.danger,
            foregroundColor: PoraColors.inkInverse,
            icon: PhosphorIconsFill.trash,
            label: context.l10n.delete,
          ),
        ],
      ),
      child: tile,
    );
  }
}
