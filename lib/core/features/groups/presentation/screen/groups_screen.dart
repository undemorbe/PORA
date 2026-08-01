import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/core/internal/network/connectivity/no_internet_banner.dart';
import 'package:pora/core/internal/widgets/deletion_dialogue.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:pora/core/features/groups/presentation/widgets/group_card.dart';
import 'package:pora/core/features/groups/presentation/widgets/groups_empty_state.dart';
import 'package:pora/core/features/groups/presentation/widgets/groups_error_state.dart';
import 'package:pora/core/features/groups/presentation/widgets/groups_loading.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_cta_card.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:pora/core/internal/network/websocket/debouncer.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';

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
    return NoInternetWrapper(
      onRetry: () async {
        await store.load();
      },

      child: Scaffold(
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
                          return const GroupsLoading();
                        }
                        if (store.errorMessage != null &&
                            store.groups.isEmpty) {
                          return GroupsErrorState(
                            message: store.errorMessage,
                            onRetry: store.load,
                          );
                        }
                        if (store.groups.isEmpty) {
                          return GroupsEmptyState(
                            onCreate: () =>
                                showCreateGroupSheet(context, store: store),
                          );
                        }
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: ListView.separated(
                            key: ValueKey(store.groups.length),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: store.groups.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: PoraSpacing.md),
                            itemBuilder: (_, i) {
                              final g = store.groups[i];
                              return FadeSlideIn(
                                key: ValueKey('grp-${g.list.id}'),
                                delay: Duration(milliseconds: 40 * i),
                                child: GroupCard(
                                  group: g,
                                  onDelete: () async {
                                    await showAdaptiveDialog(
                                      context: context,
                                      builder: (context) => DeletionDialogue(
                                        onDelete: () {
                                          store.deleteGroup(g);
                                        },
                                        title: context.l10n.groupDeletionTitle,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
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
                  // const SizedBox(height: PoraSpacing.sm),
                  // const PoraCtaCard(),
                  const SizedBox(height: PoraSpacing.sm),
                  PoraPrimaryButton(
                    label: l.groupCreate,
                    onPressed: () =>
                        showCreateGroupSheet(context, store: store),
                  ),
                  const SizedBox(height: PoraSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
