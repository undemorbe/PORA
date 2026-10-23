import 'dart:ui';

import 'package:dio/dio.dart';

/// Подставляет заголовок Authorization ко всем запросам и при 401 пытается
/// один раз обновить токен и повторить запрос.
///
/// Обычный [Interceptor], не `QueuedInterceptorsWrapper`: очередь onError
/// зависала, когда повтор или сам /refresh снова падали — их onError ждал
/// текущий onError, а тот ждал их. Параллельные 401 не плодят refresh'и:
/// `RefreshTokenUseCase` — single-flight, а запросы, ушедшие со старым
/// токеном, повторяются с уже обновлённым.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    required this.onRefresh,
    required this.onRefreshFailed,
    this.dioProvider,
  });

  /// Текущий access-токен (или null)
  final String? Function() tokenProvider;

  /// Обновить токены и вернуть новый access-токен (или null)
  final Future<String?> Function() onRefresh;

  /// Колбэк при неудачном обновлении токена (например, выход из системы)
  final VoidCallback? onRefreshFailed;

  /// Провайдер Dio (чтобы использовать настроенный экземпляр)
  final Dio Function()? dioProvider;

  static const _retriedKey = '__auth_retried';

  /// `extra`-флаг запроса: 401 не обновляет токен и не повторяет запрос.
  /// Нужен фоновым отправкам (аналитика), которые сами ретраят позже, —
  /// иначе запрос, начатый под старым юзером, повторится с токеном нового.
  static const skipAuthRefreshKey = 'skip-auth-refresh';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider();
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    final isRefreshRequest = options.path.contains('/refresh');
    final isLogoutRequest = options.path.contains('/logout');

    if (!is401 ||
        options.extra[skipAuthRefreshKey] == true ||
        options.extra[_retriedKey] == true ||
        isLogoutRequest) {
      return handler.next(err);
    }

    // Сам /refresh ответил 401 — сессия мертва
    if (isRefreshRequest) {
      onRefreshFailed?.call();
      return handler.next(err);
    }

    final String? freshToken;
    try {
      // Токен уже обновлён параллельным запросом — повторяем с ним
      final current = tokenProvider();
      final sentAuth = options.headers['Authorization'];
      freshToken = current != null && sentAuth != 'Bearer $current'
          ? current
          : await onRefresh();
    } catch (_) {
      onRefreshFailed?.call();
      return handler.next(err);
    }

    if (freshToken == null) {
      onRefreshFailed?.call();
      return handler.next(err);
    }

    final retry = options.copyWith(
      extra: {...options.extra, _retriedKey: true},
      headers: {...options.headers, 'Authorization': 'Bearer $freshToken'},
    );
    try {
      final dio = dioProvider?.call() ?? Dio();
      return handler.resolve(await dio.fetch<dynamic>(retry));
    } on DioException catch (e) {
      // 401 и со свежим токеном — выходим; сеть/5xx — просто отдаём ошибку,
      // сессию не трогаем
      if (e.response?.statusCode == 401) onRefreshFailed?.call();
      // Ошибка повтора уже прошла всю цепочку интерсепторов
      return handler.reject(e);
    }
  }
}
