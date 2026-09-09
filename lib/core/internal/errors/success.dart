import 'package:equatable/equatable.dart';

/// Семантический маркер успеха для операций без типизированного payload
/// (void-ish use-case'ы возвращают `Either<Failure, Success>`).
///
/// Если операция возвращает данные — типизируй их прямо в `Right<T>`, а не
/// складывай в `Success.data` (этого поля больше нет — было антипаттерном,
/// дублировавшим значение правой ветви).
abstract class Success extends Equatable {
  const Success([this.message = 'OK']);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Успешный ответ от сервера.
class ServerSuccess extends Success {
  const ServerSuccess([super.message = 'Успешный вызов']);
}

/// Успешная операция с локальным хранилищем.
class LocalDBSuccess extends Success {
  const LocalDBSuccess([super.message = 'Успешный вызов']);
}

/// 204 / no content — операция прошла, тело ответа пустое.
class NoContentSuccess extends Success {
  const NoContentSuccess([super.message = 'Нет содержимого']);
}

/// 201 — ресурс создан. [id] — идентификатор созданного ресурса, если есть.
class CreatedSuccess extends Success {
  const CreatedSuccess({this.id, String message = 'Создано'}) : super(message);

  final String? id;

  @override
  List<Object?> get props => [message, id];
}

/// Результат отдан из локального кэша (сеть была недоступна).
class CachedSuccess extends Success {
  const CachedSuccess([super.message = 'Данные из кэша']);
}

/// Операция поставлена в очередь на отправку (offline outbox).
class QueuedSuccess extends Success {
  const QueuedSuccess([super.message = 'Поставлено в очередь на отправку']);
}
