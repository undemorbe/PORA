import 'package:equatable/equatable.dart';
import 'package:pora/core/internal/errors/api_error_code.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

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

// 3. Ошибка отсутствия интернета
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Отсутствует подключение к интернету']);
}

// 4. Ошибка валидации форм на стороне приложения (например, пароль слишком короткий)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// 5. Unexpected
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
