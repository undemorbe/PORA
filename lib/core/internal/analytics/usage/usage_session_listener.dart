import 'package:flutter/widgets.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';

/// Связывает lifecycle приложения с сессиями [UsageTracker]:
/// `resumed` → старт сессии, `hidden`/`paused`/`detached` → конец + flush.
/// `inactive` (шторка, системный диалог) сессию не рвёт.
class UsageSessionListener {
  UsageSessionListener._();

  static AppLifecycleListener? _listener;

  /// Идемпотентно. Требует инициализированный `WidgetsBinding`.
  static void start([UsageTracker? tracker]) {
    if (_listener != null) return;
    final t = tracker ?? UsageTracker.instance;
    t.sessionStarted();
    _listener = AppLifecycleListener(
      onStateChange: (state) {
        switch (state) {
          case AppLifecycleState.resumed:
            t.sessionStarted();
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
          case AppLifecycleState.detached:
            t.sessionEnded();
          case AppLifecycleState.inactive:
            break;
        }
      },
    );
  }
}
