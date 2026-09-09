/// Signature of callbacks that have no arguments and return right or left value.
typedef Callback<T> = void Function(T value);

/// Represents a value of one of two possible types (a disjoint union).
/// Instances of [Either] are either an instance of [Left] or [Right].
/// FP Convention dictates that:
///   [Left] is used for "failure".
///   [Right] is used for "success".
abstract class Either<L, R> {
  Either() {
    if (!isLeft && !isRight) {
      throw Exception('The ether should be heir Left or Right.');
    }
  }

  /// Represents the left side of [Either] class which by convention is a "Failure".
  bool get isLeft => this is Left<L, R>;

  /// Represents the right side of [Either] class which by convention is a "Success"
  bool get isRight => this is Right<L, R>;

  L get left {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    } else {
      throw Exception('Illegal use. You should check isLeft() before calling ');
    }
  }

  R get right {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    } else {
      throw Exception('Illegal use. You should check isRight() before calling');
    }
  }

  void either(Callback<L> fnL, Callback<R> fnR) {
    if (isLeft) {
      final left = this as Left<L, R>;
      fnL(left.value);
    }

    if (isRight) {
      final right = this as Right<L, R>;
      fnR(right.value);
    }
  }

  //! --- Functional helpers (additive — не ломают isLeft/left/right) ---

  /// Сворачивает оба варианта в одно значение [T]. Основной способ
  /// обработать результат без ручных `if (isLeft)`:
  /// ```dart
  /// res.fold((f) => showError(f.message), (data) => render(data));
  /// ```
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    if (isLeft) return onLeft((this as Left<L, R>).value);
    return onRight((this as Right<L, R>).value);
  }

  /// Преобразует [Right]-значение, [Left] прокидывается как есть.
  Either<L, T> map<T>(T Function(R right) transform) {
    if (isLeft) return Left((this as Left<L, R>).value);
    return Right(transform((this as Right<L, R>).value));
  }

  /// Преобразует [Left]-значение (например, обогащает Failure).
  Either<T, R> mapLeft<T>(T Function(L left) transform) {
    if (isRight) return Right((this as Right<L, R>).value);
    return Left(transform((this as Left<L, R>).value));
  }

  /// Монадическое связывание: цепочка операций, каждая из которых
  /// сама возвращает [Either]. Первый [Left] прерывает цепочку.
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) transform) {
    if (isLeft) return Left((this as Left<L, R>).value);
    return transform((this as Right<L, R>).value);
  }

  /// Значение из [Right] или [fallback] при [Left].
  R getOrElse(R fallback) => isRight ? (this as Right<L, R>).value : fallback;

  /// `null`-safe доступ к [Right].
  R? get rightOrNull => isRight ? (this as Right<L, R>).value : null;

  /// `null`-safe доступ к [Left].
  L? get leftOrNull => isLeft ? (this as Left<L, R>).value : null;

  /// Побочный эффект только на успехе (fluent).
  Either<L, R> onSuccess(void Function(R right) fn) {
    if (isRight) fn((this as Right<L, R>).value);
    return this;
  }

  /// Побочный эффект только на ошибке (fluent).
  Either<L, R> onFailure(void Function(L left) fn) {
    if (isLeft) fn((this as Left<L, R>).value);
    return this;
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;

  Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;

  Right(this.value);
}
