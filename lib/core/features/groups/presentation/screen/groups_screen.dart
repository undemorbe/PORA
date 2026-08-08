import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/notifications/presentation/store/notifications_store.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_guard.dart';
import 'package:pora/core/internal/network/connectivity/no_internet_banner.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
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
  final GroupsStore store = GetIt.I<GroupsStore>();
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
                  Observer(
                    builder: (_) => AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      child: store.usingCache
                          ? Container(
                              margin: const EdgeInsets.only(
                                bottom: PoraSpacing.sm,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: PoraSpacing.md,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: PoraColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PoraColors.primary
                                      .withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    PhosphorIconsRegular.cloudSlash,
                                    size: 14,
                                    color: PoraColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      l.offlineReadBanner,
                                      style: PoraText.small.copyWith(
                                        color: PoraColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: PoraSpacing.lg),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
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
                        Positioned(
                          right: 0,
                          top: 0,
                          child: _NotifBell(
                            onTap: () =>
                                context.router.push(const NotificationsRoute()),
                          ),
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
                                    if (!await ConnectivityGuard.checkWrite(
                                      context,
                                    )) {
                                      return;
                                    }
                                    if (!context.mounted) return;
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
                    onPressed: () async {
                      if (!await ConnectivityGuard.checkWrite(context)) return;
                      if (!context.mounted) return;
                      context.router.push(
                        InvitationConnectRoute(linkCode: '8QwR...'),
                      );
                    },
                  ),
                  // const SizedBox(height: PoraSpacing.sm),
                  // const PoraCtaCard(),
                  const SizedBox(height: PoraSpacing.sm),
                  PoraPrimaryButton(
                    label: l.groupCreate,
                    onPressed: () async {
                      if (!await ConnectivityGuard.checkWrite(context)) return;
                      if (!context.mounted) return;
                      showCreateGroupSheet(context, store: store);
                    },
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

/// Иконка колокольчика с live-badge непрочитанных — открывает `NotificationsRoute`.
/// Читает shared `NotificationsStore` из DI (одна инстанция на приложение).
class _NotifBell extends StatelessWidget {
  const _NotifBell({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final store = GetIt.I<NotificationsStore>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Observer(
          builder: (_) {
            final unread = store.unreadCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  PhosphorIconsRegular.bell,
                  size: 20,
                  color: PoraColors.primary,
                ),
                if (unread > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: PoraColors.danger,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: PoraText.micro.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
