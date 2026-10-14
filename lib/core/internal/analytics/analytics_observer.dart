import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';

/// Логирует `screen_view` в аналитику на навигационных переходах, включая
/// переключение табов (`AutoTabsRouter` вызывает tab-колбэки только у
/// [AutoRouterObserver]). Безопасен до готовности Firebase —
/// [AnalyticsService] сам no-op'ит.
class PoraAnalyticsObserver extends AutoRouterObserver {
  void _send(String? name, {bool visit = true}) {
    if (name != null && name.isNotEmpty) {
      AnalyticsService.instance.logScreenView(name, countVisit: visit);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Модалки/диалоги без имени не считаем экранами.
    if (route is PageRoute) _send(route.settings.name);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Возврат назад — текущий экран для Firebase, но не новый «визит».
    if (route is PageRoute) _send(previousRoute?.settings.name, visit: false);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _send(newRoute?.settings.name);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) =>
      _send(route.name);

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) =>
      _send(route.name);
}
