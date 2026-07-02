import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/app/internal/JWT_access/data/datasource/local/secure.dart';
import 'package:pora/app/internal/JWT_access/domain/usecases/refresh_token.dart';
import 'package:pora/app/internal/network/interceptors/auth_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_URL'),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Добавляем интерсепторы
    dio.interceptors.addAll([
      // Auth interceptor
      AuthInterceptor(
        tokenProvider: () => GetIt.I<TokensSecureStore>().accessTokenSync,
        onRefresh: () async {
          final result = await GetIt.I<RefreshTokenUseCase>().call();
          if (result != null && result.isRight) {
            return result.right.accessToken;
          }
          return null;
        },
        onRefreshFailed: () {
          // Выход из системы при неудачном обновлении токена
          // GetIt.I<AuthRepository>().logout();
          // Можно добавить навигацию на экран входа
        },
        dioProvider: () => DioClient.instance, // Используем настроенный Dio
      ),

      // Логирование
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),

      // Обработка ошибок
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

class _ErrorInterceptor extends Interceptor {
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
