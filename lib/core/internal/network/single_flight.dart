/// Склеивает параллельные вызовы одной и той же операции в один запрос:
/// пока первый вызов в полёте, остальные получают тот же [Future].
/// Кэша результата нет — следующий вызов после завершения идёт в сеть.
class SingleFlight<T> {
  Future<T>? _inFlight;

  bool get isRunning => _inFlight != null;

  Future<T> run(Future<T> Function() task) {
    final running = _inFlight;
    if (running != null) return running;
    final future = task();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }
}
