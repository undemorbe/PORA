import 'package:pora/app/internal/di/export.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Обработка общих ошибок
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      // Ошибка таймаута
    }

    if (err.type == DioExceptionType.connectionError) {
      // Нет интернета
    }

    handler.next(err);
  }
}
