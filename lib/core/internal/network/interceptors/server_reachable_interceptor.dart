import 'package:dio/dio.dart';

/// Сообщает [onReachable] о каждом успешном ответе сервера. Нужен offline-
/// очереди: при живом транспорте возврат упавшего сервера иначе заметен
/// только по таймеру backoff.
class ServerReachableInterceptor extends Interceptor {
  ServerReachableInterceptor({required this.onReachable});

  final void Function() onReachable;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    onReachable();
    handler.next(response);
  }
}
