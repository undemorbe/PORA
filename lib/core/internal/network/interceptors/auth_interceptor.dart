import 'dart:ui';

import 'package:dio/dio.dart';

/// Подставляет заголовок Authorization ко всем запросам и при 401 пытается
/// один раз обновить токен и повторить запрос.
class AuthInterceptor extends QueuedInterceptorsWrapper {
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
    if (err.requestOptions.extra[skipAuthRefreshKey] == true) {
      return handler.next(err);
    }
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    // Не пытаемся обновить токен для запросов к /refresh или /logout
    final isRefreshRequest = err.requestOptions.path.contains('/refresh');
    final isLogoutRequest = err.requestOptions.path.contains('/logout');

    if (is401 && !alreadyRetried && !isRefreshRequest && !isLogoutRequest) {
      try {
        // Очередь 401-ок: если токен уже обновлён предыдущим запросом,
        // просто повторяем с ним, без ещё одного /authorize/refresh.
        final current = tokenProvider();
        final sentAuth = err.requestOptions.headers['Authorization'];
        final freshToken = current != null && sentAuth != 'Bearer $current'
            ? current
            : await onRefresh();

        if (freshToken != null) {
          // Создаем новый запрос с обновленным токеном
          final newRequest = err.requestOptions.copyWith(
            extra: {...err.requestOptions.extra, _retriedKey: true},
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer $freshToken',
            },
          );

          // Используем переданный Dio или создаем новый
          final dio = dioProvider?.call() ?? Dio();

          try {
            final response = await dio.fetch(newRequest);
            return handler.resolve(response);
          } catch (e) {
            // Если повторный запрос тоже упал с 401, пробуем еще раз обновить токен
            if (e is DioException && e.response?.statusCode == 401) {
              // Можно добавить логику повторного обновления
              // Но для безопасности лучше выйти из системы
              onRefreshFailed?.call();
              return handler.reject(err);
            }
            rethrow;
          }
        } else {
          // Не удалось получить новый токен
          onRefreshFailed?.call();
          return handler.reject(err);
        }
      } catch (_) {
        // Ошибка при обновлении токена
        onRefreshFailed?.call();
        return handler.reject(err);
      }
    }

    // Если это был запрос на /refresh и он упал - выходим из системы
    if (isRefreshRequest && is401) {
      onRefreshFailed?.call();
    }

    handler.next(err);
  }
}
