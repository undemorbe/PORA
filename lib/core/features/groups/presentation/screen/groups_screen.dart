import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_guard.dart';
import 'package:pora/core/internal/network/connectivity/no_internet_banner.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/deletion_dialogue.dart';
import 'package:pora/core/features/groups/data/home_view_prefs.dart';
import 'package:pora/core/features/groups/domain/entity/group.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:pora/core/features/groups/presentation/widgets/group_card.dart';
import 'package:pora/core/features/groups/presentation/widgets/groups_empty_state.dart';
import 'package:pora/core/features/groups/presentation/widgets/groups_error_state.dart';
import 'package:pora/core/features/groups/presentation/widgets/groups_loading.dart';
import 'package:pora/core/features/groups/presentation/widgets/notif_bell.dart';
import 'package:pora/core/features/groups/presentation/widgets/view_mode_toggle.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/responsive.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:pora/core/internal/network/websocket/debouncer.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
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
  final HomeViewPrefs _viewPrefs = GetIt.I<HomeViewPrefs>();
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
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

  Future<void> _loadViewMode() async {
    final grid = await _viewPrefs.isGrid();
    if (!mounted) return;
    setState(() => _isGrid = grid);
  }

  Future<void> _toggleViewMode() async {
    setState(() => _isGrid = !_isGrid);
    await _viewPrefs.setGrid(_isGrid);
    unawaited(AnalyticsService.instance.logViewModeChanged(grid: _isGrid));
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      key: ValueKey('list-${store.groups.length}'),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: store.groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: PoraSpacing.md),
      itemBuilder: (_, i) {
        final g = store.groups[i];
        return FadeSlideIn(
          key: ValueKey('grp-${g.list.id}'),
          delay: Duration(milliseconds: 40 * i),
          child: _groupTile(context, g),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context) {
    return LayoutBuilder(
      key: ValueKey('grid-${store.groups.length}'),
      builder: (context, constraints) {
        // В явном grid-режиме держим минимум 2 колонки даже на телефоне —
        // иначе 1 колонка визуально не отличается от списка.
        final cols = gridColumnsFor(constraints.maxWidth).clamp(2, 4);
        const spacing = PoraSpacing.md;
        final cellW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var i = 0; i < store.groups.length; i++)
                SizedBox(
                  width: cellW,
                  child: FadeSlideIn(
                    key: ValueKey('grp-grid-${store.groups[i].list.id}'),
                    delay: Duration(milliseconds: 30 * i),
                    child: _groupTile(context, store.groups[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _groupTile(BuildContext context, GroupEntity g) {
    return GroupCard(
      group: g,
      onDelete: () async {
        if (!await ConnectivityGuard.checkWrite(context)) return;
        if (!context.mounted) return;
        await showAdaptiveDialog(
          context: context,
          builder: (context) => DeletionDialogue(
            onDelete: () => store.deleteGroup(g),
            title: context.l10n.groupDeletionTitle,
          ),
        );
      },
    );
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
            child: AdaptiveContainer(
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
                                color: PoraColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PoraColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
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
                          left: 0,
                          top: 0,
                          child: ViewModeToggle(
                            isGrid: _isGrid,
                            onTap: _toggleViewMode,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: NotifBell(
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
                          child: _isGrid
                              ? _buildGrid(context)
                              : _buildList(context),
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
      ),
    );
  }
}

