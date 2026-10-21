import 'dart:async';

import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_entry.dart';

/// Обработчик одного типа операции: выполняет реальный remote-вызов.
/// Должен бить по сети НАПРЯМУЮ (remote), не через сервис с outbox — иначе
/// при повторном офлайне операция уйдёт в очередь снова (петля).
typedef OutboxHandler =
    Future<Either<Failure, Object?>> Function(Map<String, dynamic> args);

/// Фабрика таймеров — подменяется в тестах.
typedef TimerFactory = Timer Function(Duration delay, void Function() callback);

/// Итог одного прохода [OutboxReplayer.flush].
class FlushOutcome {
  const FlushOutcome({
    this.replayed = 0,
    this.dropped = const [],
    this.paused = false,
    this.wasSkipped = false,
  });

  /// Flush уже шёл — этот вызов ничего не делал.
  static const skipped = FlushOutcome(wasSkipped: true);

  /// Сколько записей успешно ушло на сервер.
  final int replayed;

  /// Записи, отброшенные навсегда (4xx или TTL) — их оптимистичный патч
  /// оказался неправдой.
  final List<OutboxEntry> dropped;

  /// Проход прерван из-за проблем со связью — остаток ждёт повтора.
  final bool paused;

  /// Вызов пропущен, потому что уже шёл другой flush.
  final bool wasSkipped;

  bool get hasChanges => replayed > 0 || dropped.isNotEmpty;
}

class OutboxReplayer {
  OutboxReplayer({
    required this.outbox,
    bool Function()? isOnline,
    TimerFactory? timerFactory,
    DateTime Function()? now,
  }) : _isOnline = isOnline ?? (() => true),
       _timerFactory = timerFactory ?? Timer.new,
       _now = now ?? DateTime.now;

  /// Запись старше этого срока считается протухшей и отбрасывается.
  static const ttl = Duration(days: 7);

  /// Задержка flush после постановки новой записи — даём серии тапов
  /// собраться в одну отправку.
  static const enqueueDelay = Duration(seconds: 3);

  static const _minBackoff = Duration(seconds: 5);
  static const _maxBackoff = Duration(minutes: 5);

  final Outbox outbox;
  final bool Function() _isOnline;
  final TimerFactory _timerFactory;
  final DateTime Function() _now;
  final Map<String, OutboxHandler> _handlers = {};
  final _events = StreamController<FlushOutcome>.broadcast();

  StreamSubscription<void>? _changesSub;
  Timer? _timer;
  DateTime? _dueAt;
  Duration? _backoff;
  bool _flushing = false;

  /// Во время flush пришёл ещё один вызов — после завершения нужен повтор,
  /// иначе записи, поставленные после снимка очереди, ждут следующего триггера.
  bool _rerun = false;

  /// После [dispose] таймеры и подписки больше не заводятся.
  bool _disposed = false;

  /// Итоги flush'ей, в которых что-то ушло на сервер или было отброшено.
  /// Экраны перезагружаются по нему, OutboxSyncEffects показывает snackbar.
  Stream<FlushOutcome> get events => _events.stream;

  /// Текущая задержка повтора после ошибки связи; `null` — повтор не нужен.
  Duration? get currentBackoff => _backoff;

  void register(String kind, OutboxHandler handler) {
    _handlers[kind] = handler;
  }

  /// Подписка на новые записи очереди: при онлайне — flush через
  /// [enqueueDelay] (сервер мог быть недоступен лишь кратковременно).
  void start() {
    if (_disposed) return;
    _changesSub ??= outbox.changes.listen((_) {
      if (_isOnline()) scheduleFlush(enqueueDelay);
    });
  }

  /// Планирует flush через [delay]. Если уже запланирован более ранний —
  /// ничего не делает; более поздний — перепланирует.
  void scheduleFlush(Duration delay) {
    if (_disposed) return;
    final due = _now().add(delay);
    final current = _dueAt;
    if (current != null && !due.isBefore(current)) return;
    _timer?.cancel();
    _dueAt = due;
    _timer = _timerFactory(delay, () {
      _timer = null;
      _dueAt = null;
      unawaited(flush());
    });
  }

  Future<FlushOutcome> flush() async {
    if (_flushing) {
      _rerun = true;
      return FlushOutcome.skipped;
    }
    _flushing = true;
    var replayed = 0;
    final dropped = <OutboxEntry>[];
    var paused = false;
    try {
      final entries = await outbox.all();
      if (entries.isNotEmpty) {
        Logger.talker.info('Outbox flush: ${entries.length} pending');
      }
      final now = _now();
      for (final entry in entries) {
        // Снимок взят в начале flush — запись могли выкинуть коалесингом,
        // пока проигрывались предыдущие.
        if (!await outbox.contains(entry.id)) continue;

        final created = DateTime.fromMillisecondsSinceEpoch(entry.createdAt);
        if (now.difference(created) > ttl) {
          Logger.talker.warning('Outbox: dropping stale ${entry.kind}');
          await outbox.remove(entry.id);
          dropped.add(entry);
          continue;
        }

        final handler = _handlers[entry.kind];
        if (handler == null) {
          Logger.talker.warning('Outbox: no handler for ${entry.kind}, drop');
          await outbox.remove(entry.id);
          continue;
        }
        entry.attempts++;
        await outbox.update(entry);

        final Either<Failure, Object?> res;
        try {
          res = await handler(entry.args);
        } catch (e, s) {
          // Баг в обработчике — повтор не поможет; не блокируем остальную
          // очередь, запись считаем «отравленной».
          Logger.talker.error(
            'Outbox: ${entry.kind} handler threw, drop',
            e,
            s,
          );
          await outbox.remove(entry.id);
          dropped.add(entry);
          continue;
        }
        if (res.isRight) {
          await outbox.remove(entry.id);
          replayed++;
          continue;
        }

        final failure = res.left;
        if (failure.isConnectivity) {
          // Связь (или сервер) снова недоступна — остальное проиграем позже.
          Logger.talker.info('Outbox flush paused: ${failure.message}');
          paused = true;
          break;
        }
        // Постоянная ошибка — запись «отравленная», убираем.
        Logger.talker.warning(
          'Outbox: dropping ${entry.kind} after permanent error: '
          '${failure.message}',
        );
        await outbox.remove(entry.id);
        dropped.add(entry);
      }
    } catch (e, s) {
      Logger.talker.error('Outbox flush failed', e, s);
      paused = true;
    } finally {
      _flushing = false;
    }

    final outcome = FlushOutcome(
      replayed: replayed,
      dropped: dropped,
      paused: paused,
    );
    _afterFlush(outcome);
    return outcome;
  }

  void _afterFlush(FlushOutcome outcome) {
    if (_disposed) return;
    final rerun = _rerun;
    _rerun = false;
    if (outcome.paused) {
      final prev = _backoff;
      final next = prev == null ? _minBackoff : prev * 2;
      _backoff = next > _maxBackoff ? _maxBackoff : next;
      // Офлайн — таймер не нужен: flush запустит reaction на online.
      if (_isOnline()) scheduleFlush(_backoff!);
    } else {
      _backoff = null;
      // На паузе повтор и так придёт по backoff или reaction на online.
      if (rerun) scheduleFlush(Duration.zero);
    }
    if (outcome.hasChanges && !_events.isClosed) _events.add(outcome);
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _dueAt = null;
    await _changesSub?.cancel();
    _changesSub = null;
    await _events.close();
  }
}
