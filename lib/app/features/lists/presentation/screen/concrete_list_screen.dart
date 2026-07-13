import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/features/lists/presentation/widgets/add_list_button.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_header.dart';
import 'package:pora/app/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';

/// Конкретный список покупок выбранной семьи.
@RoutePage()
class ListPage extends StatefulWidget {
  const ListPage({
    super.key,
    required this.listId,
    required this.listName,
    required this.members,
  });

  final String listId;

  final String listName;

  final List<MemberEntity> members;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  /// Контроллер
  late final ListStore listStore;

  @override
  void initState() {
    super.initState();
    listStore = ListStore()..getConcreteList(lid: widget.listId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AddListButton(
        onTap: () => context.router.push(const AddItemRoute()),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: () => listStore.getConcreteList(lid: widget.listId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PoraSpacing.screen,
              PoraSpacing.sm,
              PoraSpacing.screen,
              100, // место под плавающую кнопку
            ),
            children: [
              ListHeader(
                //! Do search, recipe, notifications
                title: widget.listName,
                subtitle:
                    "${widget.members.length} ${context.l10n.human} · ${listStore.productsAmount} ${context.l10n.products}",
                members: widget.members,
                onSearch: () => context.router.push(const SearchRoute()),
                onRecipe: () => context.router.push(const RecipeImportRoute()),
                onNotifications: () =>
                    context.router.push(const NotificationsRoute()),
              ),
              const SizedBox(height: PoraSpacing.xl),
              SectionBuilder(listStore: listStore, isPreview: false),
            ],
          ),
        ),
      ),
    );
  }
}
