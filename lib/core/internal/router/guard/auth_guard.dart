import 'package:auto_route/auto_route.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';

/// Пропускает в защищённые маршруты только авторизованных.
/// В паре с `reevaluateListenable` (см. AppRouter.config): после
/// login/logout роутер сам пере-оценивает стек — колбэки не нужны.
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._auth);

  final AuthState _auth;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_auth.status == AuthStatus.authenticated) {
      resolver.next();
    } else {
      // Уводим на экран входа и запоминаем исходный маршрут:
      // как только _auth станет authenticated и сработает reevaluate,
      // навигация доведётся до изначальной цели автоматически.
      resolver.redirectUntil(const AuthRoute());
    }
  }
}
