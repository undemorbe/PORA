import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/notifications/presentation/widgets/notification_tile.dart';
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
                Text('Уведомления', style: PoraText.title),
                Text(
                  'Прочитать все',
                  style: PoraText.caption.copyWith(
                    color: PoraColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),
            const PoraRowsCard(
              children: [
                NotificationTile(
                  emoji: '⏰',
                  tileColor: PoraColors.primaryTintStrong,
                  title: 'По дороге домой захвати молоко',
                  body: 'Оно кончилось — Анна отметила 10 минут назад.',
                  time: '5 минут назад',
                  unread: true,
                ),
                NotificationTile(
                  emoji: '🔮',
                  tileColor: PoraColors.primaryTint,
                  title: 'Скоро закончится кофе',
                  body: 'Покупаете ~раз в 14 дней, прошло 12.',
                  mini: true,
                  unread: true,
                ),
                NotificationTile(
                  emoji: '👤',
                  tileColor: PoraColors.successTint,
                  title: 'Анна добавила 2 продукта',
                  body: 'Бананы и Хлеб — в общем списке.',
                  time: 'Сегодня, 9:12',
                ),
                NotificationTile(
                  emoji: '🎁',
                  tileColor: PoraColors.sandSoft,
                  title: '−15% на первый заказ в Самокате',
                  body: 'Промо активно ещё 6 дней.',
                  time: 'Вчера',
                ),
                NotificationTile(
                  emoji: '✅',
                  tileColor: PoraColors.successTint,
                  title: 'Заказ доставлен',
                  body: '8 продуктов · Самокат · ₽1 054.',
                  time: 'Вчера',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
