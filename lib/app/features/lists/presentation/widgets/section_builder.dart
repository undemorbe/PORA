import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/features/lists/presentation/widgets/section_group.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';

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
    void isListOnTap(ListSectionEntity list) {
      context.router.push(
        ListRoute(listId: list.id, listName: list.name, members: members ?? []),
      );
    }

    void isProductOnTap(ProductEntity product) {
      context.router.push(const ItemDetailRoute());
    }

    if (listStore.list == null) {
      return Center(child: Text(context.l10n.tryToUpdate));
    } else if (isPreview == true && listStore.listsWithPreview == null) {
      return Center(child: Text(context.l10n.tryToUpdate));
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        //! Handle item detail
        return SectionGroup(
          section: isPreview
              ? listStore.listsWithPreview!.lists[index]
              : listStore.list!.sections[index],
          onProductTap: isPreview ? null : isProductOnTap,
          onListTap: isPreview ? isListOnTap : null,
        );
      },
      itemCount: listStore.listsWithPreview?.lists.length,
    );
  }
}
