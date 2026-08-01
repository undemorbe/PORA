import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Единая ловушка ошибок приложения. Всё летит в Talker (в дебаге —
/// ещё и в консоль через `FlutterError.presentError`).
///
/// Использование:
/// ```dart
/// void main() => ErrorZone.run(() async { runApp(...); });
/// ```
class ErrorZone {
  const ErrorZone._();

  /// Оборачивает [body] в защищённую зону. Хендлит:
  ///   - Flutter framework errors (`FlutterError.onError`)
  ///   - Uncaught platform errors (`PlatformDispatcher.instance.onError`)
  ///   - Uncaught async errors (`runZonedGuarded`)
  static Future<void> run(FutureOr<void> Function() body) async {
    // 1. Flutter engine → Talker.
    FlutterError.onError = (details) {
      Logger.talker.handle(details.exception, details.stack, 'FlutterError');
      if (kDebugMode) FlutterError.presentError(details);
    };

    // 2. Platform (движок Dart за пределами Flutter) → Talker.
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.talker.handle(error, stack, 'PlatformDispatcher');
      return true;
    };

    // 3. Async зона.
    await runZonedGuarded(body, (error, stack) {
      Logger.talker.handle(error, stack, 'ZoneError');
    });
  }
}
