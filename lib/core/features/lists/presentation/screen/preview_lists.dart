import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:pora/core/internal/network/websocket/debouncer.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:pora/core/features/lists/presentation/store/lists_store.dart';
import 'package:pora/core/features/lists/presentation/widgets/add_list_button.dart';
import 'package:pora/core/features/lists/presentation/widgets/create_list_sheet.dart';
import 'package:pora/core/features/lists/presentation/widgets/list_header.dart';
import 'package:pora/core/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/core/features/families/presentation/store/selected_family_store.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';

/// Превью списков.
/// - `isPersonal == true` → личные списки пользователя (без members/invite).
/// - иначе → списки семьи (нужны familyId/familyName/members).
@RoutePage()
class PreviewListsPage extends StatefulWidget {
  const PreviewListsPage({
    super.key,
    this.familyId,
    this.familyName,
    this.members,
    this.isPersonal = false,
  });

  final String? familyId;
  final String? familyName;
  final List<MemberEntity>? members;
  final bool isPersonal;

  @override
  State<PreviewListsPage> createState() => _PreviewListsPageState();
}

class _PreviewListsPageState extends State<PreviewListsPage> {
  late final ListStore listStore;
  StreamSubscription<WsDataModel>? _wsSub;
  final _debouncer = Debouncer();

  bool get _isPersonal => widget.isPersonal;

  @override
  void initState() {
    super.initState();
    listStore = ListStore();
    _refresh();
    if (!_isPersonal) _subscribeWs();
  }

  void _subscribeWs() {
    _wsSub = AppWebsocket.instance.events.listen((event) {
      // Preview слушает изменения в текущей семье:
      //   family-id (только) → member joined / renamed
      //   family-id + list-id → список создан/удалён/переименован
      final matchesFamily = event.fid == widget.familyId;
      if (!matchesFamily) return;
      final isListEvent = event.lid != null && event.iid == null;
      final isFamilyOnly = event.lid == null && event.iid == null;
      if (isListEvent || isFamilyOnly) {
        _debouncer.call(_refresh);
      }
    });
  }

  Future<void> _refresh() {
    if (_isPersonal) return listStore.loadPersonalLists();
    return listStore.getFamilyLists(fid: widget.familyId ?? '');
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _debouncer.cancel();
    super.dispose();
  }

  void _openCreateSheet() {
    showCreateListSheet(
      context,
      listStore: listStore,
      // Личные — без familyId, backend создаёт под пользователем.
      familyId: _isPersonal ? null : widget.familyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AddListButton(onTap: _openCreateSheet),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: _refresh,
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
                  final count = listStore.listsWithPreview?.lists.length ?? 0;
                  if (_isPersonal) {
                    return ListHeader(
                      title: context.l10n.personal,
                      subtitle: '$count ${context.l10n.lists}',
                      members: const [],
                      onBack: () => context.router.maybePop(),
                    );
                  }
                  final members = widget.members ?? const <MemberEntity>[];
                  return ListHeader(
                    title: widget.familyName ?? '',
                    subtitle:
                        "${members.length} ${context.l10n.human} · $count ${context.l10n.lists}",
                    members: members,
                    onBack: () => context.router.maybePop(),
                    onMembersTap: members.isEmpty
                        ? null
                        : () => context.router.push(
                            MembersRoute(
                              members: members,
                              ownerId: GetIt.I<SelectedFamilyStore>()
                                  .current
                                  ?.owner
                                  .id,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: PoraSpacing.xl),
              SectionBuilder(
                listStore: listStore,
                isPreview: true,
                members: widget.members,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
