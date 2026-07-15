import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:pora/app/features/notifications/domain/entity/notification_entity.dart';
import 'package:pora/app/features/notifications/presentation/store/notifications_store.dart';
import 'package:pora/app/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';

/// Центр уведомлений: live-список из Hive + приход по FCM в foreground.
@RoutePage()
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsStore store = NotificationsStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: store.load,
          child: Observer(
            builder: (context) {
              final items = store.items;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  PoraSpacing.screen,
                  6,
                  PoraSpacing.screen,
                  PoraSpacing.xxl,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.notificationsTitle,
                        style: PoraText.title,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: store.unreadCount == 0
                            ? null
                            : () => store.markAllRead(),
                        child: Text(
                          context.l10n.notificationsReadAll,
                          style: PoraText.caption.copyWith(
                            color: store.unreadCount == 0
                                ? PoraColors.textMuted
                                : PoraColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.lg),
                  if (store.isLoading && items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: PoraSpacing.xl),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: PoraSpacing.xxl,
                      ),
                      child: Center(
                        child: Text(
                          context.l10n.tryToUpdate,
                          style: PoraText.subtitle,
                        ),
                      ),
                    )
                  else
                    PoraRowsCard(
                      children: [
                        for (final n in items)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: n.unread ? () => store.markRead(n.id) : null,
                            child: NotificationTile(
                              emoji: _emojiFor(n),
                              tileColor: _colorFor(n),
                              title: n.title ?? '',
                              body: n.body ?? '',
                              time: _formatTime(n.receivedAt),
                              unread: n.unread,
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _emojiFor(NotificationEntity n) {
    final type = n.data['type']?.toString();
    switch (type) {
      case 'urgent':
        return '⏰';
      case 'prediction':
        return '🔮';
      case 'partner_added':
        return '👤';
      case 'promo':
        return '🎁';
      case 'order_delivered':
        return '✅';
      default:
        return '🔔';
    }
  }

  Color _colorFor(NotificationEntity n) {
    final type = n.data['type']?.toString();
    switch (type) {
      case 'urgent':
        return PoraColors.primaryTintStrong;
      case 'prediction':
        return PoraColors.primaryTint;
      case 'partner_added':
      case 'order_delivered':
        return PoraColors.successTint;
      case 'promo':
        return PoraColors.sandSoft;
      default:
        return PoraColors.sandSoft;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final sameDay = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
    return sameDay
        ? DateFormat.Hm().format(dt)
        : DateFormat('d MMM').format(dt);
  }
}
