import 'dart:async';

/// Статус авторизации на уровне навигации.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Единый источник правды об авторизации для роутера.
/// Отдаёт [stream] в `router.config(reevaluateListenable:
/// ReevaluateListenable.stream(...))` — при каждом изменении статуса
/// auto_route заново прогоняет гварды.
class AuthState {
  AuthStatus _status = AuthStatus.unknown;
  final _controller = StreamController<AuthStatus>.broadcast();

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Поток изменений статуса для reevaluateListenable.
  Stream<AuthStatus> get stream => _controller.stream;

  void setAuthenticated() => _set(AuthStatus.authenticated);
  void setUnauthenticated() => _set(AuthStatus.unauthenticated);

  void _set(AuthStatus next) {
    if (_status == next) return;
    _status = next;
    _controller.add(next);
  }

  void dispose() => _controller.close();
}
