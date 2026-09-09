import 'package:equatable/equatable.dart';
import 'package:pora/core/internal/errors/api_error_code.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  /// `true` если ошибка связана с доступностью сети (offline / timeout).
  /// Кэш-слой (`cachedOrLive`) откатывается на сохранённые данные только
  /// для таких ошибок, а не для 4xx/валидации.
  bool get isConnectivity => false;

  @override
  List<Object?> get props => [message];
}

/// Ошибка от бэка с типизированным [code]. UI и usecase'ы могут ветвиться:
/// `if (f is ApiFailure && f.code == ApiErrorCode.otpExpired) …`.
class ApiFailure extends Failure {
  const ApiFailure({
    required this.code,
    required String message,
    this.statusCode,
  }) : super(message);

  final ApiErrorCode code;
  final int? statusCode;

  bool get isAuthLoss =>
      code == ApiErrorCode.unauthorized ||
      code == ApiErrorCode.accessTokenExpired ||
      code == ApiErrorCode.refreshTokenExpired;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// 404 — ресурс не найден. Подтип [ApiFailure], поэтому `is ApiFailure`
/// и ветвление по `code` продолжают работать.
class NotFoundFailure extends ApiFailure {
  const NotFoundFailure({
    required super.code,
    required super.message,
    super.statusCode = 404,
  });
}

/// 409 — конфликт состояния (например, дубликат / устаревшая версия).
class ConflictFailure extends ApiFailure {
  const ConflictFailure({
    required super.code,
    required super.message,
    super.statusCode = 409,
  });
}

/// 429 — слишком много запросов. [retryAfterSeconds] — из заголовка
/// `Retry-After`, если пришёл.
class RateLimitFailure extends ApiFailure {
  const RateLimitFailure({
    required super.message,
    this.retryAfterSeconds,
    super.statusCode = 429,
  }) : super(code: ApiErrorCode.unknown);

  final int? retryAfterSeconds;

  @override
  List<Object?> get props => [message, code, statusCode, retryAfterSeconds];
}

// 1. Ошибка сервера (например, API вернул 500 или 404)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// 2. Ошибка локального кэша (не удалось записать токен в SharedPreferences или базу)
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Ошибка при работе с локальным хранилищем',
  ]);
}

/// Запрошенных данных нет ни в сети, ни в кэше (offline + пустой кэш).
class CacheMissFailure extends Failure {
  const CacheMissFailure([super.message = 'Нет сохранённых данных офлайн']);
}

// 3. Ошибка отсутствия интернета
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Отсутствует подключение к интернету']);

  @override
  bool get isConnectivity => true;
}

/// Истекло время ожидания ответа (connect/send/receive timeout).
/// Считается connectivity-ошибкой для целей кэш-фолбэка.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Превышено время ожидания ответа']);

  @override
  bool get isConnectivity => true;
}

// 4. Ошибка валидации форм на стороне приложения (например, пароль слишком короткий)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// 5. Unexpected
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
