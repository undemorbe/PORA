import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/features/lists/presentation/widgets/add_list_button.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_header.dart';
import 'package:pora/app/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';

/// Concrete list screen.
///
/// `listId` — единственный обязательный аргумент. `listName`/`members`
/// опциональны: если не переданы (deeplink, тап из уведомления) —
/// подтягиваются из ответа `/lists/{lid}` (name из entity, members
/// собираются из `product.addedBy`).
@RoutePage()
class ListPage extends StatefulWidget {
  const ListPage({
    super.key,
    required this.listId,
    this.listName,
    this.members,
  });

  final String listId;
  final String? listName;
  final List<MemberEntity>? members;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final ListStore listStore;
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listStore = ListStore()..getConcreteList(lid: widget.listId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        listStore.clearQuery();
      }
    });
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
              100,
            ),
            children: [
              Observer(
                builder: (context) {
                  final title = widget.listName ??
                      listStore.list?.name ??
                      '';
                  final members = widget.members?.isNotEmpty == true
                      ? widget.members!
                      : listStore.derivedMembers;
                  return ListHeader(
                    title: title,
                    subtitle:
                        "${members.length} ${context.l10n.human} · ${listStore.productsAmount} ${context.l10n.products}",
                    members: members,
                    onSearch: _toggleSearch,
                    onRecipe: () =>
                        context.router.push(const RecipeImportRoute()),
                    onNotifications: () =>
                        context.router.push(const NotificationsRoute()),
                  );
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _searchOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: PoraSpacing.md),
                        child: _SearchField(
                          controller: _searchController,
                          onChanged: listStore.setQuery,
                          onClose: _toggleSearch,
                        ),
                      )
                    : const SizedBox.shrink(),
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: PoraRadii.input,
        border: Border.all(color: PoraColors.border),
        boxShadow: PoraShadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.md),
      child: Row(
        children: [
          const PhosphorIcon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 18,
            color: PoraColors.textMuted,
          ),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: PoraText.body,
              decoration: InputDecoration(
                hintText: context.l10n.searchHint,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: PoraSpacing.md,
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: PoraSpacing.xs),
              child: PhosphorIcon(
                PhosphorIconsRegular.x,
                size: 16,
                color: PoraColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
