import 'package:dio/dio.dart';
import 'package:pora/core/internal/errors/api_error_code.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Единый переводчик исключений в [Failure]. Использовать в сервисах:
/// ```dart
/// try { … } catch (e, s) { return Left(FailureMapper.map(e, s)); }
/// ```
class FailureMapper {
  const FailureMapper._();

  static Failure map(Object error, [StackTrace? stack]) {
    // Логируем всё в Talker — для дебага и Error-Zone аудита.
    Logger.talker.handle(error, stack);

    if (error is DioException) return _fromDio(error);
    if (error is FormatException) return ServerFailure(error.message);
    return UnexpectedFailure(error.toString());
  }

  static Failure _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(e.message ?? 'Request timed out');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return UnexpectedFailure(e.message ?? 'Cancelled');
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
      // Fallback для новых DioExceptionType (например, transformTimeout).
      // ignore: unreachable_switch_default
      default:
        return _fromBody(e);
    }
  }

  static ApiFailure _fromBody(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String codeRaw = '';
    String message = e.message ?? 'HTTP ${status ?? "?"}';

    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map<String, dynamic>) {
        codeRaw = (err['code'].toString() as String?) ?? '';
        message = (err['message'] as String?) ?? message;
      } else if (err is String) {
        message = err;
      }
    }

    final code = ApiErrorCode.fromWire(codeRaw);

    // Специализированные подтипы для well-known статусов — сохраняют
    // `is ApiFailure` + `code`, но позволяют точечное ветвление в UI.
    switch (status) {
      case 404:
        return NotFoundFailure(code: code, message: message);
      case 409:
        return ConflictFailure(code: code, message: message);
      case 429:
        return RateLimitFailure(
          message: message,
          retryAfterSeconds: _retryAfter(e),
        );
    }

    return ApiFailure(code: code, message: message, statusCode: status);
  }

  static int? _retryAfter(DioException e) {
    final raw = e.response?.headers.value('retry-after');
    if (raw == null) return null;
    return int.tryParse(raw.trim());
  }
}
