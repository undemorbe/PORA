import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/notifications/domain/entity/notification_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/features/notifications/presentation/store/notifications_store.dart';
import 'package:pora/core/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Центр уведомлений: filter chips, группировка по дням, slidable delete,
/// menu «Очистить все». Live-стрим приходит по FCM в foreground.
@RoutePage()
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Shared store — bell на groups и эта страница видят один state.
  final NotificationsStore store = GetIt.I<NotificationsStore>();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  // dispose не нужен — store общий, живёт всё приложение.

  Future<void> _confirmClearAll() async {
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(context.l10n.notificationsClearAll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.notificationsDelete,
              style: const TextStyle(color: PoraColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await store.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: store.load,
          child: Observer(
            builder: (context) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      PoraSpacing.screen,
                      6,
                      PoraSpacing.screen,
                      PoraSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _Header(
                        title: l.notificationsTitle,
                        unreadCount: store.unreadCount,
                        onBack: () => context.router.maybePop(),
                        onReadAll:
                            store.unreadCount == 0 ? null : store.markAllRead,
                        onClearAll:
                            store.items.isEmpty ? null : _confirmClearAll,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _FilterChips(
                      selected: store.filter,
                      onSelect: store.setFilter,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: PoraSpacing.md),
                  ),
                  if (store.isLoading && store.items.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else if (store.filtered.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    _GroupedList(store: store),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.unreadCount,
    required this.onBack,
    required this.onReadAll,
    required this.onClearAll,
  });

  final String title;
  final int unreadCount;
  final VoidCallback onBack;
  final VoidCallback? onReadAll;
  final Future<void> Function()? onClearAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const PhosphorIcon(
            PhosphorIconsRegular.caretLeft,
            size: 26,
          ),
        ),
        const SizedBox(width: PoraSpacing.md),
        Expanded(
          child: Row(
            children: [
              Text(title, style: PoraText.title),
              if (unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const BoxDecoration(
                    color: PoraColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: PoraText.micro.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onReadAll != null)
          TextButton(
            onPressed: onReadAll,
            child: Text(
              context.l10n.notificationsReadAll,
              style: PoraText.small.copyWith(
                color: PoraColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        PopupMenuButton<String>(
          icon: Icon(PhosphorIconsRegular.dotsThreeVertical, color: c.ink),
          onSelected: (v) {
            if (v == 'clear') onClearAll?.call();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'clear',
              enabled: onClearAll != null,
              child: Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.trash,
                    size: 16,
                    color: PoraColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.notificationsClearAll),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelect});
  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final chips = <(NotificationFilter, String)>[
      (NotificationFilter.all, l.notificationsFilterAll),
      (NotificationFilter.urgent, l.notificationsFilterUrgent),
      (NotificationFilter.prediction, l.notificationsFilterPrediction),
      (NotificationFilter.promo, l.notificationsFilterPromo),
      (NotificationFilter.other, l.notificationsFilterOther),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.screen),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (f, label) = chips[i];
          return _Chip(
            label: label,
            active: f == selected,
            onTap: () => onSelect(f),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? PoraColors.primary : c.surface,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: Border.all(
            color: active ? PoraColors.primary : c.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: PoraText.small.copyWith(
            color: active ? Colors.white : c.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.store});
  final NotificationsStore store;

  String _label(BuildContext ctx, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return ctx.l10n.notificationsGroupToday;
    if (diff == 1) return ctx.l10n.notificationsGroupYesterday;
    final locale = Localizations.localeOf(ctx).toString();
    return DateFormat('d MMMM', locale).format(day);
  }

  @override
  Widget build(BuildContext context) {
    final groups = store.groupedByDay();
    return SliverList.builder(
      itemCount: groups.length,
      itemBuilder: (_, gIdx) {
        final g = groups[gIdx];
        return FadeSlideIn(
          delay: Duration(milliseconds: 40 * gIdx),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PoraSpacing.screen,
              PoraSpacing.sm,
              PoraSpacing.screen,
              PoraSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    _label(context, g.day),
                    style: PoraText.small.copyWith(
                      color: context.colors.textSubtle,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                PoraRowsCard(
                  children: [
                    for (final n in g.items)
                      _SlidableRow(
                        key: ValueKey('notif-${n.id}'),
                        notif: n,
                        onTap: n.unread ? () => store.markRead(n.id) : null,
                        onDelete: () => store.delete(n.id),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SlidableRow extends StatelessWidget {
  const _SlidableRow({
    super.key,
    required this.notif,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationEntity notif;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  static String _emojiFor(NotificationEntity n) {
    final type = n.data['type']?.toString();
    return switch (type) {
      'urgent' => '⏰',
      'prediction' => '🔮',
      'partner_added' => '👤',
      'promo' => '🎁',
      'order_delivered' => '✅',
      _ => '🔔',
    };
  }

  static Color _colorFor(NotificationEntity n) {
    final type = n.data['type']?.toString();
    return switch (type) {
      'urgent' => PoraColors.primaryTintStrong,
      'prediction' => PoraColors.primaryTint,
      'partner_added' || 'order_delivered' => PoraColors.successTint,
      'promo' => PoraColors.sandSoft,
      _ => PoraColors.sandSoft,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey('slide-${notif.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: PoraColors.danger,
            foregroundColor: Colors.white,
            icon: PhosphorIconsRegular.trash,
            label: context.l10n.notificationsDelete,
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: NotificationTile(
          emoji: _emojiFor(notif),
          tileColor: _colorFor(notif),
          title: notif.title ?? '',
          body: notif.body ?? '',
          time: DateFormat.Hm().format(notif.receivedAt),
          unread: notif.unread,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PoraSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              tween: Tween(begin: 0.6, end: 1.0),
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsFill.bell,
                  size: 52,
                  color: c.textSubtle,
                ),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            Text(
              l.notificationsEmptyTitle,
              style: PoraText.itemTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              l.notificationsEmptyBody,
              style: PoraText.small.copyWith(color: c.textSubtle),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
