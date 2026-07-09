import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';

/// Центр уведомлений: срочность, предсказания, действия партнёра, партнёрка.
@RoutePage()
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                Text(context.l10n.notificationsTitle, style: PoraText.title),
                Text(
                  context.l10n.notificationsReadAll,
                  style: PoraText.caption.copyWith(
                    color: PoraColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),
            PoraRowsCard(
              children: [
                NotificationTile(
                  emoji: '⏰',
                  tileColor: PoraColors.primaryTintStrong,
                  title: context.l10n.notificationsMilkTitle,
                  body: context.l10n.notificationsMilkBody,
                  time: context.l10n.notificationsMilkTime,
                  unread: true,
                ),
                NotificationTile(
                  emoji: '🔮',
                  tileColor: PoraColors.primaryTint,
                  title: context.l10n.notificationsCoffeeTitle,
                  body: context.l10n.notificationsCoffeeBody,
                  mini: true,
                  unread: true,
                ),
                NotificationTile(
                  emoji: '👤',
                  tileColor: PoraColors.successTint,
                  title: context.l10n.notificationsPartnerAddedTitle,
                  body: context.l10n.notificationsPartnerAddedBody,
                  time: context.l10n.notificationsPartnerAddedTime,
                ),
                NotificationTile(
                  emoji: '🎁',
                  tileColor: PoraColors.sandSoft,
                  title: context.l10n.notificationsPromoTitle,
                  body: context.l10n.notificationsPromoBody,
                  time: context.l10n.notificationsPromoTime,
                ),
                NotificationTile(
                  emoji: '✅',
                  tileColor: PoraColors.successTint,
                  title: context.l10n.notificationsOrderDeliveredTitle,
                  body: context.l10n.notificationsOrderDeliveredBody,
                  time: context.l10n.notificationsPromoTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
