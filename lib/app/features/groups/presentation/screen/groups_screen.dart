import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/internal/widgets/deletion_dialogue.dart';
import 'package:pora/app/features/groups/presentation/store/groups_store.dart';
import 'package:pora/app/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:pora/app/features/groups/presentation/widgets/group_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/network/websocket/app_websocket.dart';
import 'package:pora/app/internal/network/websocket/debouncer.dart';
import 'package:pora/app/internal/network/websocket/model/ws_data_model.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';

/// Экран групп. Группа = список.
@RoutePage()
class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final GroupsStore store = GroupsStore();
  StreamSubscription<WsDataModel>? _sub;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    try {
      store.load();
      _sub = AppWebsocket.instance.events.listen((e) {
        // Любое событие → refresh (общая переорганизация — редко, ok).
        _debouncer.call((() {
         store.load(); 
        }));
      });
    } on Exception {
      // TODO
    }
    
  }

  @override
  void dispose() {
    _sub?.cancel();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            6,
            PoraSpacing.screen,
            PoraSpacing.xxs,
          ),
          child: RefreshIndicator.adaptive(
            onRefresh: store.load,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: PoraSpacing.lg),
                  child: Column(
                    children: [
                      Text(l.groupsTitle, style: PoraText.title),
                      const SizedBox(height: 6),
                      Text(
                        l.groupsSubtitle,
                        style: PoraText.caption.copyWith(
                          color: context.colors.textSubtle,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Observer(
                    builder: (context) {
                      if (store.isLoading && store.groups.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      if (store.groups.isEmpty) {
                        return Center(
                          child: Text(
                            l.noGroups,
                            style: PoraText.subtitle.copyWith(
                              color: context.colors.textSubtle,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: store.groups.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: PoraSpacing.md),
                        itemBuilder: (_, i) {
                          final g = store.groups[i];
                          return GroupCard(
                            group: g,
                            onDelete: () async {
                              await showAdaptiveDialog(
                                context: context,
                                builder: (context) => DeletionDialogue(
                                  onDelete: () {
                                    store.deleteGroup(g);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: PoraSpacing.sm),
                PoraOutlineButton(
                  label: l.groupConnect,
                  onPressed: () => context.router.push(
                    InvitationConnectRoute(linkCode: '8QwR...'),
                  ),
                ),
                const SizedBox(height: PoraSpacing.sm),
                PoraPrimaryButton(
                  label: l.groupCreate,
                  onPressed: () => showCreateGroupSheet(context, store: store),
                ),
                const SizedBox(height: PoraSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
