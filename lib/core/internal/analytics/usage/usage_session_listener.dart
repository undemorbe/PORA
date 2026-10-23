import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';

/// Связывает lifecycle приложения с сессиями [UsageTracker] и backend-очередью:
/// `resumed` → старт сессии (+ `session_start` на бэкенд),
/// `hidden`/`paused`/`detached` → конец сессии, flush трекера и очереди.
/// `inactive` (шторка, системный диалог) сессию не рвёт.
class UsageSessionListener {
  UsageSessionListener._();

  static AppLifecycleListener? _listener;

  /// Идемпотентно. Требует инициализированный `WidgetsBinding`.
  static void start([UsageTracker? tracker]) {
    if (_listener != null) return;
    final t = tracker ?? UsageTracker.instance;

    void begin() {
      if (t.sessionStarted()) {
        unawaited(AnalyticsService.instance.logSessionStart());
      }
    }

    begin();
    _listener = AppLifecycleListener(
      onStateChange: (state) {
        switch (state) {
          case AppLifecycleState.resumed:
            begin();
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
          case AppLifecycleState.detached:
            t.sessionEnded();
            unawaited(BackendEventSink.instance.flush());
          case AppLifecycleState.inactive:
            break;
        }
      },
    );
  }
}
