import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
 final String message;
 const Failure(this.message);

 @override
 List<Object?> get props => [message];
}

// 1. Ошибка сервера (например, API вернул 500 или 404)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Произошла ошибка на сервере']);
}

// 2. Ошибка локального кэша (не удалось записать токен в SharedPreferences или базу)
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка при работе с локальным хранилищем']);
}

// 3. Ошибка отсутствия интернета
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Отсутствует подключение к интернету']);
}

// 4. Ошибка валидации форм на стороне приложения (например, пароль слишком короткий)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}