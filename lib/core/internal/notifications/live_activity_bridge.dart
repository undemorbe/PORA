import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Мост к нативному iOS LiveActivity (ActivityKit) через MethodChannel.
class LiveActivityBridge {
  const LiveActivityBridge._();

  static const MethodChannel _channel = MethodChannel('pora/live_activity');

  static bool get _supported => Platform.isIOS;

  /// Запускает (или обновляет, если уже идёт для itemId) Live Activity с уже
  /// локализованными title/subtitle. Возвращает `true`, если натив принял.
  static Future<bool> start({
    required String itemId,
    required String title,
    String subtitle = '',
    String actionLabel = '',
  }) async {
    if (!_supported) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('start', {
        'itemId': itemId,
        'title': title,
        'subtitle': subtitle,
        'actionLabel': actionLabel,
      });
      return ok ?? false;
    } on MissingPluginException {
      // Нативный target ещё не добавлен — тихо падаем на notification-fallback.
      return false;
    } on PlatformException catch (e) {
      Logger.talker.warning('LiveActivity start failed: ${e.message}');
      return false;
    }
  }

  /// Завершает Live Activity для [itemId] (товар куплен / отменён).
  static Future<void> end(String itemId) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('end', {'itemId': itemId});
    } on MissingPluginException {
      // no-op
    } on PlatformException catch (e) {
      Logger.talker.warning('LiveActivity end failed: ${e.message}');
    }
  }
}
