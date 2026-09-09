import 'package:flutter/widgets.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';

/// Логирует `screen_view` в аналитику на навигационных переходах.
/// Безопасен до готовности Firebase — [AnalyticsService] сам no-op'ит.
class PoraAnalyticsObserver extends NavigatorObserver {
  void _send(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      AnalyticsService.instance.logScreenView(name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _send(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _send(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _send(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
