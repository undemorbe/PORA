import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/features/auth_and_validation/data/datasource/local/secure_tokens.dart';
import 'package:pora/core/features/auth_and_validation/domain/usecase/refresh_token.dart';
import 'package:pora/core/features/user/domain/usecase/user/logout.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/network/interceptors/auth_interceptor.dart';
import 'package:pora/core/internal/network/interceptors/error_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

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
        onRefreshFailed: () async {
          await GetIt.I<LogoutUseCase>().call();
        },
        dioProvider: () => DioClient.instance, // Используем настроенный Dio
      ),

      // Логирование
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
        talker: Logger.talker,
      ),

      // Обработка ошибок
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
