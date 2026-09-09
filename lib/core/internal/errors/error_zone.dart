import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Единая ловушка ошибок приложения. Всё летит в Talker (в дебаге —
/// ещё и в консоль через `FlutterError.presentError`) и, когда Firebase
/// готов, дублируется в Crashlytics.
///
/// Использование:
/// ```dart
/// void main() => ErrorZone.run(() async { runApp(...); });
/// ```
class ErrorZone {
  const ErrorZone._();

  /// Crashlytics инициализируется в AppBootstrap ПОСЛЕ `Firebase.initializeApp`
  /// (горячий старт держим минимальным). До этого момента ошибки идут только в
  /// Talker — поэтому перед каждым обращением проверяем `Firebase.apps`.
  static bool get _crashlyticsReady => Firebase.apps.isNotEmpty;

  static void _recordToCrashlytics(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    if (!_crashlyticsReady) return;
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
    } catch (_) {
      // Crashlytics ещё не готов / не сконфигурирован — молча пропускаем.
    }
  }

  /// Оборачивает [body] в защищённую зону. Хендлит:
  ///   - Flutter framework errors (`FlutterError.onError`)
  ///   - Uncaught platform errors (`PlatformDispatcher.instance.onError`)
  ///   - Uncaught async errors (`runZonedGuarded`)
  static Future<void> run(FutureOr<void> Function() body) async {
    // 1. Flutter engine → Talker + Crashlytics.
    FlutterError.onError = (details) {
      Logger.talker.handle(details.exception, details.stack, 'FlutterError');
      if (_crashlyticsReady) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      }
      if (kDebugMode) FlutterError.presentError(details);
    };

    // 2. Platform (движок Dart за пределами Flutter) → Talker + Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.talker.handle(error, stack, 'PlatformDispatcher');
      _recordToCrashlytics(error, stack, fatal: true);
      return true;
    };

    // 3. Async зона.
    await runZonedGuarded(body, (error, stack) {
      Logger.talker.handle(error, stack, 'ZoneError');
      _recordToCrashlytics(error, stack);
    });
  }
}
