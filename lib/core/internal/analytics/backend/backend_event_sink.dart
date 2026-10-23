import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pora/core/internal/analytics/backend/analytics_event.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Результат отправки батча: отправлен, повторить позже, выбросить (4xx).
enum SendOutcome { sent, retry, drop }

/// Отправляет батч событий (уже в JSON-формате API) и классифицирует ответ.
typedef AnalyticsBatchSender =
    Future<SendOutcome> Function(List<Map<String, dynamic>> events);

/// Персистентная очередь клиентских событий для `POST /api/analytics/events`.
///
/// До [attach] события копятся в памяти. После — очередь хранится JSON-строкой
/// под [storageKey] в `LocalDBNames.settings`, отправляется батчами по
/// таймеру [flushInterval], при накоплении [flushThreshold] и по явному
/// [flush] (уход в фон, логин, появление сети). Шлём только когда
/// `canSend()` (авторизован + онлайн). Сеть/5xx → экспоненциальный backoff,
/// 4xx → батч выбрасывается, чтобы битые данные не блокировали очередь.
class BackendEventSink {
  BackendEventSink({DateTime Function()? clock, Random? random})
    : _clock = clock ?? DateTime.now,
      _random = random ?? Random.secure();

  static final BackendEventSink instance = BackendEventSink();

  static const storageKey = 'analytics-queue-v1';
  static const maxQueue = 1000;
  static const flushThreshold = 50;
  static const maxBatch = 100;
  static const flushInterval = Duration(seconds: 30);
  static const initialBackoff = Duration(seconds: 30);
  static const maxBackoff = Duration(minutes: 10);
  static const _persistDelay = Duration(seconds: 1);

  final DateTime Function() _clock;
  final Random _random;
  final List<AnalyticsEvent> _queue = [];

  ILocalDB<dynamic>? _db;
  AnalyticsBatchSender? _sender;
  bool Function() _canSend = _never;
  String? _platform;
  String _appVersion = '';
  bool _disabled = false;

  Timer? _flushTimer;
  Timer? _persistTimer;
  Future<void>? _inFlight;
  int _failures = 0;
  DateTime? _retryAfter;

  static bool _never() => false;

  @visibleForTesting
  List<AnalyticsEvent> get pending => List.unmodifiable(_queue);

  /// Текущая задержка до следующей попытки (null — backoff не активен).
  @visibleForTesting
  Duration? get retryDelay => _failures == 0 ? null : _backoffFor(_failures);

  /// Ставит событие в очередь. Синхронно и без исключений.
  void track(String name, [Map<String, Object> props = const {}]) {
    if (_disabled) return;
    _queue.add(
      AnalyticsEvent(
        id: uuidV4(_random),
        name: name,
        props: props,
        occurredAt: _clock(),
      ),
    );
    _trimToCap();
    if (_db == null) return;
    _schedulePersist();
    if (_queue.length >= flushThreshold) unawaited(flush());
  }

  /// Подключает хранилище и отправку. [platform] == null — платформа не
  /// поддерживается бэкендом: sink отключается и очищает очередь.
  Future<void> attach({
    required ILocalDB<dynamic> db,
    required AnalyticsBatchSender sender,
    required bool Function() canSend,
    required String? platform,
    required String appVersion,
  }) async {
    if (_db != null || _disabled) return;
    if (platform == null) {
      _disabled = true;
      _queue.clear();
      return;
    }
    _db = db;
    _sender = sender;
    _canSend = canSend;
    _platform = platform;
    _appVersion = appVersion;
    try {
      final raw = await db.get(key: storageKey, boxName: LocalDBNames.settings);
      _queue.insertAll(0, _decode(raw));
      _trimToCap();
    } catch (e, s) {
      Logger.talker.warning('BackendEventSink: load failed', e, s);
    }
    _schedulePersist();
    _flushTimer = Timer.periodic(flushInterval, (_) => unawaited(flush()));
  }

  /// Отправляет очередь, пока она не пуста и отправка разрешена.
  /// Параллельные вызовы ждут одну и ту же отправку.
  ///
  /// Предусловия проверяются синхронно, до записи [_inFlight]: иначе вызов
  /// сразу после «пустого» flush получил бы уже завершившийся future и
  /// ничего бы не отправил.
  Future<void> flush() {
    final running = _inFlight;
    if (running != null) return running;
    if (!_readyToDrain()) return Future.value();
    return _inFlight = _drain().whenComplete(() => _inFlight = null);
  }

  /// Немедленная запись очереди на диск.
  Future<void> persistNow() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    final db = _db;
    if (db == null) return;
    try {
      await db.set(
        key: storageKey,
        value: jsonEncode([for (final e in _queue) e.toStorage()]),
        boxName: LocalDBNames.settings,
      );
    } catch (e, s) {
      Logger.talker.warning('BackendEventSink: persist failed', e, s);
    }
  }

  /// Полная очистка (logout — события нового юзера не смешиваем со старыми).
  Future<void> clear() async {
    _persistTimer?.cancel();
    _queue.clear();
    _failures = 0;
    _retryAfter = null;
    try {
      await _db?.delete(key: storageKey, boxName: LocalDBNames.settings);
    } catch (e, s) {
      Logger.talker.warning('BackendEventSink: clear failed', e, s);
    }
  }

  @visibleForTesting
  void dispose() {
    _flushTimer?.cancel();
    _persistTimer?.cancel();
  }

  //! --- internals ---

  bool _readyToDrain() {
    if (_sender == null || _platform == null) return false;
    if (_queue.isEmpty || !_canSend()) return false;
    final retryAfter = _retryAfter;
    return retryAfter == null || !_clock().isBefore(retryAfter);
  }

  Future<void> _drain() async {
    final sender = _sender!;
    final platform = _platform!;

    while (_queue.isNotEmpty && _canSend()) {
      final batch = _queue.take(maxBatch).toList();
      final outcome = await sender([
        for (final e in batch)
          e.toJson(platform: platform, appVersion: _appVersion),
      ]);

      if (outcome == SendOutcome.retry) {
        _failures++;
        _retryAfter = _clock().add(_backoffFor(_failures));
        break;
      }
      if (outcome == SendOutcome.drop) {
        Logger.talker.warning(
          'BackendEventSink: batch of ${batch.length} rejected by server, dropped',
        );
      }

      final sentIds = {for (final e in batch) e.id};
      _queue.removeWhere((e) => sentIds.contains(e.id));
      _failures = 0;
      _retryAfter = null;
    }

    await persistNow();
  }

  Duration _backoffFor(int failures) {
    final factor = 1 << (failures - 1).clamp(0, 10);
    final delay = initialBackoff * factor;
    return delay > maxBackoff ? maxBackoff : delay;
  }

  void _trimToCap() {
    if (_queue.length > maxQueue) {
      _queue.removeRange(0, _queue.length - maxQueue);
    }
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(_persistDelay, () => unawaited(persistNow()));
  }

  static List<AnalyticsEvent> _decode(Object? raw) {
    if (raw is! String || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [for (final e in decoded) ?AnalyticsEvent.fromStorage(e)];
  }
}
