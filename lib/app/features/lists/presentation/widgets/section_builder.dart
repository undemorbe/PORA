import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_item_tile.dart';
import 'package:pora/app/features/lists/presentation/widgets/section_group.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

const int _kPreviewProductsLimit = 3;

class SectionBuilder extends StatelessWidget {
  const SectionBuilder({
    super.key,
    required this.listStore,
    required this.isPreview,
    this.members,
  });

  final ListStore listStore;
  final bool isPreview;
  final List<MemberEntity>? members;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (listStore.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: PoraSpacing.xl),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (listStore.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(PoraSpacing.lg),
              child: Text(
                listStore.errorMessage ?? context.l10n.tryToUpdate,
                style: PoraText.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return isPreview ? _buildPreview(context) : _buildConcrete(context);
      },
    );
  }

  Widget _buildPreview(BuildContext context) {
    final lists = listStore.listsWithPreview?.lists ?? const <ListEntity>[];
    if (lists.isEmpty) {
      return Center(child: Text(context.l10n.tryToUpdate));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final list in lists)
          Padding(
            padding: const EdgeInsets.only(bottom: PoraSpacing.lg),
            child: _PreviewListCard(
              list: list,
              members: members ?? const [],
            ),
          ),
      ],
    );
  }

  Widget _buildConcrete(BuildContext context) {
    final hasList = listStore.list != null;
    if (!hasList) {
      return Center(child: Text(context.l10n.tryToUpdate));
    }
    final sections = listStore.filteredSections;
    if (sections.isEmpty) {
      final emptyLabel = listStore.query.trim().isEmpty
          ? context.l10n.tryToUpdate
          : context.l10n.searchNothingFound;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xl),
        child: Center(child: Text(emptyLabel, style: PoraText.subtitle)),
      );
    }

    void onProductTap(ProductEntity _) {
      context.router.push(const ItemDetailRoute());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections)
          SectionGroup(section: section, onProductTap: onProductTap),
      ],
    );
  }
}

class _PreviewListCard extends StatelessWidget {
  const _PreviewListCard({required this.list, required this.members});

  final ListEntity list;
  final List<MemberEntity> members;

  @override
  Widget build(BuildContext context) {
    final allItems = <ProductEntity>[
      for (final s in list.sections) ...s.items,
    ];
    final visible = allItems.take(_kPreviewProductsLimit).toList();
    final hidden = allItems.length - visible.length;

    void openList() => context.router.push(
      ListRoute(listId: list.id, listName: list.name, members: members),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openList,
      child: PoraCard(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.lg,
                PoraSpacing.md,
                PoraSpacing.lg,
                PoraSpacing.xs,
              ),
              child: Text(list.name, style: PoraText.heading),
            ),
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoraSpacing.lg,
                  vertical: PoraSpacing.md,
                ),
                child: Text(
                  context.l10n.familiesNoUrgent,
                  style: PoraText.subtitle,
                ),
              )
            else
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: PoraSpacing.lg,
                    endIndent: PoraSpacing.lg,
                    color: Theme.of(context).dividerColor,
                  ),
                ListItemTile(
                  item: visible[i],
                  addedBy: visible[i].addedBy,
                  isCompact: true,
                  onTap: openList,
                ),
              ],
            if (hidden > 0)
              _ShowAllButton(
                label: '${context.l10n.showAll} ($hidden)',
                onTap: openList,
              ),
          ],
        ),
      ),
    );
  }
}

class _ShowAllButton extends StatelessWidget {
  const _ShowAllButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: PoraRadii.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.lg,
          vertical: PoraSpacing.md,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: PoraText.button.copyWith(color: PoraColors.primary),
            ),
            const Spacer(),
            const PhosphorIcon(
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
