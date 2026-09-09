import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/features/lists/presentation/store/lists_store.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:pora/core/internal/network/websocket/debouncer.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:pora/core/features/lists/presentation/widgets/add_list_button.dart';
import 'package:pora/core/features/lists/presentation/widgets/list_header.dart';
import 'package:pora/core/features/lists/presentation/widgets/list_search_field.dart';
import 'package:pora/core/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';

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
    this.ownerId,
  });

  final String listId;
  final String? listName;
  final List<MemberEntity>? members;
  final String? ownerId;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final ListStore listStore;
  bool _searchOpen = false;
  final _searchController = TextEditingController();
  StreamSubscription<WsDataModel>? _wsSub;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    listStore = ListStore()..getConcreteList(lid: widget.listId);
    _wsSub = AppWebsocket.instance.events.listen((event) {
      if (event.lid != widget.listId && listStore.isSelfUpdated == false) {
        return;
      }
      _debouncer.call(_refresh);
    });
  }

  Future<void> _refresh() => listStore.getConcreteList(lid: widget.listId);

  @override
  void dispose() {
    _searchController.dispose();
    _wsSub?.cancel();
    _debouncer.cancel();
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
        onTap: () async {
          await context.router.push(AddItemRoute(lid: widget.listId));
        },
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
                  final title = widget.listName ?? listStore.list?.name ?? '';
                  final members = widget.members?.isNotEmpty == true
                      ? widget.members!
                      : listStore.derivedMembers;
                  return ListHeader(
                    title: title,
                    subtitle: members.length == 1
                        ? "${context.l10n.onlyYou} · ${listStore.productsAmount} ${context.l10n.products}"
                        : "${members.length} ${context.l10n.human} · ${listStore.productsAmount} ${context.l10n.products}",
                    members: members,
                    onBack: () => context.router.maybePop(),
                    onSearch: _toggleSearch,
                    onRecipe: () => context.router.push(
                      RecipeImportRoute(lid: widget.listId),
                    ),
                    onNotifications: () =>
                        context.router.push(const NotificationsRoute()),
                    onMembersTap: members.isEmpty
                        ? null
                        : () => context.router.push(
                            MembersRoute(
                              members: members,
                              ownerId: widget.ownerId,
                            ),
                          ),
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
                        child: ListSearchField(
                          controller: _searchController,
                          onChanged: listStore.setQuery,
                          onClose: _toggleSearch,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: PoraSpacing.xl),
              SectionBuilder(
                listStore: listStore,
                isPreview: false,
                lid: widget.listId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
