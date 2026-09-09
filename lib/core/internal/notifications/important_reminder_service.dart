import 'dart:convert';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/features/item_detail/domain/usecase/mark_item_bought.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/localization/store/localization_store.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/notifications/live_activity_bridge.dart';

/// Кросс-платформенный аналог iOS LiveActivity.
class ImportantReminderService {
  ImportantReminderService(this._local);

  final FlutterLocalNotificationsPlugin _local;

  /// Отдельный канал — максимальная важность, звук, без группировки с обычными.
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'important_reminders',
    'Важные напоминания',
    description: 'Срочные просьбы купить товар',
    importance: Importance.max,
  );

  /// actionId кнопки «Куплено» в уведомлении.
  static const String actionMarkBought = 'REMINDER_MARK_BOUGHT';

  /// Детерминированный id из item-id: повторный [show] обновляет то же
  /// уведомление, а не плодит новые.
  int _idFor(String itemId) => itemId.hashCode & 0x7fffffff;

  /// Локализация без BuildContext — по активной локали приложения.
  AppLocalizations get _l =>
      lookupAppLocalizations(Locale(GetIt.I<LocalizationStore>().currentLocale));

  /// Регистрирует канал (вызывать один раз при инициализации нотификаций).
  Future<void> ensureChannel() async {
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Показывает/обновляет важное напоминание о покупке [productName],
  /// запрошенной пользователем [fromUser]. [itemId] нужен, чтобы действие
  /// «Куплено» отметило конкретный товар и сняло напоминание.
  Future<void> show({
    required String itemId,
    required String productName,
    String? fromUser,
  }) async {
    final l = _l;
    final title = l.importantReminderTitle(productName);
    final subtitle = (fromUser == null || fromUser.isEmpty)
        ? ''
        : l.importantReminderFrom(fromUser);
    final fullTitle = subtitle.isEmpty ? title : '$title $subtitle';

    // iOS 16.1+: пытаемся поднять настоящий LiveActivity (Dynamic Island /
    // экран блокировки) — строки уже локализованы. Если нативный target не
    // подключён — вернёт false, и ниже покажется уведомление как fallback.
    await LiveActivityBridge.start(
      itemId: itemId,
      title: title,
      subtitle: subtitle,
      actionLabel: l.importantReminderMarkBought,
    );

    await _local.show(
      id: _idFor(itemId),
      title: fullTitle,
      body: l.importantReminderBody,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
          ongoing: true, // нельзя смахнуть свайпом
          autoCancel: false,
          actions: [
            AndroidNotificationAction(
              actionMarkBought,
              l.importantReminderMarkBought,
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
          categoryIdentifier: 'important_reminders',
          presentBanner: true,
        ),
      ),
      payload: jsonEncode({
        'type': 'urgent',
        'reminder': true,
        'item-id': itemId,
      }),
    );
  }

  /// Снимает напоминание (товар куплен / более не актуален) — и уведомление,
  /// и нативный LiveActivity (если был запущен).
  Future<void> dismiss(String itemId) async {
    await LiveActivityBridge.end(itemId);
    await _local.cancel(id: _idFor(itemId));
  }

  /// Обрабатывает тап по кнопке действия в уведомлении. Возвращает `true`,
  /// если это было действие напоминания (дальше роутинг не нужен).
  Future<bool> handleAction(
    String? actionId,
    Map<String, dynamic> payload,
  ) async {
    if (actionId != actionMarkBought) return false;
    final itemId = payload['item-id']?.toString();
    if (itemId == null || itemId.isEmpty) return true;
    try {
      await GetIt.I<MarkItemBoughtUseCase>().call(
        itemId: itemId,
        checked: true,
      );
    } catch (e, s) {
      Logger.talker.warning('Important reminder: mark bought failed', e, s);
    }
    await dismiss(itemId);
    return true;
  }
}
