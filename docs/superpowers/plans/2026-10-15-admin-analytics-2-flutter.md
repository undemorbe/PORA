# Admin-аналитика, план 2 из 3 — Flutter: события на бэкенд и распил Insights

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Клиентские события (сессии, экраны, AI, рецепты, поддержка, режим отображения) уходят батчами на `POST /api/analytics/events` через персистентную очередь с retry; `insights_screen.dart` разбит на независимые section-виджеты без изменения поведения.

**Architecture:** `AnalyticsService` остаётся единым фасадом и раздаёт события в три приёмника: Firebase (`_log`), локальный `UsageTracker` и новый `BackendEventSink`. Доменные события (товар добавлен/куплен/удалён, список создан) пишет сервер — в `BackendEventSink` они **не** идут. Sink хранит очередь JSON-строкой в `LocalDBNames.settings` (как `UsageTracker`), шлёт только когда `AuthState.isAuthenticated && ConnectivityStore.online`, повторяет с экспоненциальной задержкой, 4xx-батчи выбрасывает.

**Tech Stack:** Flutter (Dart ^3.12), MobX, Dio + retrofit, Hive через `ILocalDB`, GetIt, `package_info_plus` (новая зависимость), `fake_async` в тестах.

**Spec:** `docs/superpowers/specs/2026-10-15-admin-analytics-design.md` (§1.2, §3.1)

**Зависимости:** бэкенд-контракт `POST /api/analytics/events` — план 1, Task 9. Клиент можно писать и тестировать до деплоя бэкенда (sender мокается), но ручная проверка Task 6 требует бэкенда с планом 1.

---

## ⚠️ Предусловие

На момент написания плана в рабочем дереве `lib/` были **незакоммиченные изменения параллельной работы** (groups-фича, recipe-скрейпер, AI-события в `AnalyticsService`: `logAiResponse`, `logRecipeImportFailed`, `logTipGenerated({required bool fromFallback})`, `logRecipeImport({source, extractor, host, ingredients, durationMs})`). План написан **против этой версии** `analytics_service.dart`.

- [ ] **Step 0: Убедись, что параллельные изменения закоммичены**

Run: `git status --short lib/ pubspec.yaml test/`
Expected: пусто. Если нет — **остановись и спроси пользователя**, не коммить чужие изменения и не начинай план поверх них.

Затем: `grep -n "logTipGenerated\|logRecipeImport(" lib/core/internal/analytics/analytics_service.dart` — сигнатуры должны совпадать с указанными выше. Если отличаются — адаптируй Task 4 Step 3 к фактическим сигнатурам (меняется только список параметров, логика `_backend.track(...)` та же).

## Решения, уточнённые при планировании

1. **(отклонение от spec §3.1)** Очередь хранится не в отдельном Hive-box `pora-analytics-queue`, а ключом `analytics-queue-v1` в `LocalDBNames.settings` через `ILocalDB` — так же, как `UsageTracker`. Причина: тестируемость через существующий `FakeLocalDB`, без регистрации нового box в `HiveLocalDB`.
2. **UUID** генерируется собственной функцией `uuidV4()` (`Random.secure()`), без пакета `uuid`.
3. **Платформа** — из `defaultTargetPlatform` (`ios`/`android`). На других платформах sink отключается (бэкенд принимает только `ios|android`).
4. **`UsageTracker.sessionStarted()` возвращает `bool`** (true — началась новая сессия), чтобы `session_start` уходил ровно один раз на сессию.
5. **Секции Insights принимают данные, а не store** — их можно тестировать виджет-тестами без DI. Выбор «чемпиона» (сервер vs локальный топ) переезжает в чистую функцию `pickChampion` + `@computed champion` в `StatisticsStore`.
6. **Коды ответа:** `202/2xx` → отправлено; сеть/таймаут/`5xx`/`401`/`408`/`429` → retry; прочие `4xx` → батч выбрасывается.

## Карта файлов

| Файл | Ответственность |
|---|---|
| `lib/core/internal/analytics/backend/analytics_event.dart` (new) | событие очереди, `uuidV4`, JSON для сети и хранилища |
| `lib/core/internal/analytics/backend/backend_event_sink.dart` (new) | очередь, персист, flush-триггеры, backoff, cap |
| `lib/core/internal/analytics/backend/api_analytics_sender.dart` (new) | отправка через `ApiClient` + классификация ошибок |
| `lib/core/internal/analytics/analytics_service.dart` (mod) | fan-out client-only событий в sink, test-конструктор |
| `lib/core/internal/analytics/usage/usage_tracker.dart` (mod) | `sessionStarted()` → `bool` |
| `lib/core/internal/analytics/usage/usage_session_listener.dart` (mod) | `session_start` + flush при уходе в фон |
| `lib/core/internal/network/api_client/api_client.dart` (mod, + `.g.dart` codegen) | `sendAnalyticsEvents` |
| `lib/core/internal/bootstrap/app_bootstrap.dart` (mod) | attach sink, flush при логине/появлении сети |
| `lib/core/features/settings/presentation/store/settings_store.dart` (mod) | flush перед logout, clear после |
| `lib/core/features/insights/presentation/store/statistics_store.dart` (mod, + `.g.dart`) | `pickChampion`, `@computed champion` |
| `lib/core/features/insights/presentation/widgets/sections/*.dart` (new) | 8 секций экрана |
| `lib/core/features/insights/presentation/screen/insights_screen.dart` (mod) | только композиция секций |
| `pubspec.yaml` (mod) | `package_info_plus` |
| `test/unit/analytics_event_test.dart`, `backend_event_sink_test.dart`, `api_analytics_sender_test.dart`, `analytics_service_fanout_test.dart`, `statistics_champion_test.dart` (new) | unit-тесты |
| `test/widget/insights_sections_test.dart` (new) | виджет-тесты секций |

## Общие команды

```bash
dart run build_runner build                       # после правок ApiClient / store (флаг --delete-conflicting-outputs не добавлять — CLAUDE.md)
dart format lib test
flutter analyze lib/core/internal/analytics lib/core/features/insights lib/core/internal/bootstrap
flutter test --exclude-tags golden
```

---

### Task 1: Событие очереди и UUID

**Files:**
- Create: `lib/core/internal/analytics/backend/analytics_event.dart`
- Test: `test/unit/analytics_event_test.dart`

- [ ] **Step 1: Напиши падающий тест**

`test/unit/analytics_event_test.dart`:

```dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/backend/analytics_event.dart';

void main() {
  test('uuidV4 has RFC 4122 v4 shape and is unique', () {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final ids = {for (var i = 0; i < 200; i++) uuidV4(Random(i))};
    expect(ids, hasLength(200));
    expect(ids.every(pattern.hasMatch), isTrue);
  });

  test('toJson uses kebab-case keys and UTC ISO time', () {
    final event = AnalyticsEvent(
      id: 'id-1',
      name: 'recipe_import',
      props: const {'source': 'youtube'},
      occurredAt: DateTime.utc(2026, 10, 15, 10),
    );

    expect(event.toJson(platform: 'ios', appVersion: '1.4.0'), {
      'id': 'id-1',
      'name': 'recipe_import',
      'props': {'source': 'youtube'},
      'platform': 'ios',
      'app-version': '1.4.0',
      'occurred-at': '2026-10-15T10:00:00.000Z',
    });
  });

  test('storage roundtrip keeps fields; garbage is skipped', () {
    final event = AnalyticsEvent(
      id: 'id-2',
      name: 'view_mode_changed',
      props: const {'grid': true},
      occurredAt: DateTime.utc(2026, 10, 15, 9, 30),
    );

    final restored = AnalyticsEvent.fromStorage(event.toStorage());
    expect(restored?.id, 'id-2');
    expect(restored?.props, {'grid': true});
    expect(restored?.occurredAt, DateTime.utc(2026, 10, 15, 9, 30));

    expect(AnalyticsEvent.fromStorage('nope'), isNull);
    expect(AnalyticsEvent.fromStorage({'id': 1}), isNull);
  });
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `flutter test test/unit/analytics_event_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:pora/core/internal/analytics/backend/analytics_event.dart'`

- [ ] **Step 3: Реализуй**

`lib/core/internal/analytics/backend/analytics_event.dart`:

```dart
import 'dart:math';

/// Клиентское событие аналитики в очереди [BackendEventSink].
///
/// [id] генерируется на клиенте — по нему сервер отсекает повторную
/// отправку (`ON CONFLICT DO NOTHING`). Платформа и версия приложения
/// подставляются в момент отправки.
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.id,
    required this.name,
    required this.props,
    required this.occurredAt,
  });

  final String id;
  final String name;
  final Map<String, Object> props;
  final DateTime occurredAt;

  /// Формат `POST /api/analytics/events` (ключи kebab-case).
  Map<String, dynamic> toJson({
    required String platform,
    required String appVersion,
  }) => {
    'id': id,
    'name': name,
    'props': props,
    'platform': platform,
    'app-version': appVersion,
    'occurred-at': occurredAt.toUtc().toIso8601String(),
  };

  /// Формат хранения очереди на диске.
  Map<String, dynamic> toStorage() => {
    'id': id,
    'name': name,
    'props': props,
    'at': occurredAt.toUtc().toIso8601String(),
  };

  /// Восстанавливает событие из [toStorage]; битую запись пропускает (null).
  static AnalyticsEvent? fromStorage(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final at = DateTime.tryParse('${raw['at']}');
    if (id is! String || name is! String || at == null) return null;
    final rawProps = raw['props'];
    return AnalyticsEvent(
      id: id,
      name: name,
      props: rawProps is Map
          ? {
              for (final e in rawProps.entries)
                if (e.value != null) '${e.key}': e.value as Object,
            }
          : const {},
      occurredAt: at,
    );
  }
}

/// UUID v4 (RFC 4122) без внешних зависимостей.
String uuidV4([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // версия 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // вариант RFC 4122
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `flutter test test/unit/analytics_event_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/internal/analytics/backend/analytics_event.dart test/unit/analytics_event_test.dart
git commit -m "feat(analytics): client analytics event model and uuidV4"
```

---

### Task 2: `BackendEventSink` — очередь, персист, flush, backoff

**Files:**
- Create: `lib/core/internal/analytics/backend/backend_event_sink.dart`
- Test: `test/unit/backend_event_sink_test.dart`

- [ ] **Step 1: Напиши падающие тесты**

`test/unit/backend_event_sink_test.dart`:

```dart
import 'dart:convert';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

import '../helpers/fake_local_db.dart';

class _Sender {
  final List<List<Map<String, dynamic>>> batches = [];
  SendOutcome outcome = SendOutcome.sent;

  Future<SendOutcome> call(List<Map<String, dynamic>> events) async {
    batches.add(events);
    return outcome;
  }

  int get sentEvents => batches.fold(0, (sum, b) => sum + b.length);
}

void main() {
  late DateTime clock;
  late FakeLocalDB db;
  late _Sender sender;
  late bool canSend;
  late BackendEventSink sink;

  BackendEventSink newSink() =>
      BackendEventSink(clock: () => clock, random: Random(7));

  Future<void> attach(BackendEventSink s, {String? platform = 'ios'}) =>
      s.attach(
        db: db,
        sender: sender.call,
        canSend: () => canSend,
        platform: platform,
        appVersion: '1.4.0',
      );

  setUp(() {
    clock = DateTime.utc(2026, 10, 15, 10);
    db = FakeLocalDB();
    sender = _Sender();
    canSend = true;
    sink = newSink();
  });

  tearDown(() => sink.dispose());

  test('events before attach are kept and sent with platform/version', () async {
    sink.track('session_start');
    sink.track('recipe_import', const {'source': 'youtube'});
    expect(sink.pending, hasLength(2));

    await attach(sink);
    await sink.flush();

    expect(sender.batches, hasLength(1));
    final first = sender.batches.single.first;
    expect(first['name'], 'session_start');
    expect(first['platform'], 'ios');
    expect(first['app-version'], '1.4.0');
    expect(first['occurred-at'], '2026-10-15T10:00:00.000Z');
    expect(sink.pending, isEmpty);
  });

  test('queue survives restart via storage', () async {
    canSend = false;
    await attach(sink);
    sink.track('ai_chat_opened');
    await sink.persistNow();
    sink.dispose();

    final restored = newSink();
    await attach(restored);
    expect(restored.pending.single.name, 'ai_chat_opened');
    restored.dispose();
  });

  test('nothing is sent while canSend is false', () async {
    canSend = false;
    await attach(sink);
    sink.track('session_start');
    await sink.flush();
    expect(sender.batches, isEmpty);
    expect(sink.pending, hasLength(1));
  });

  test('retry keeps batch and backs off; success after delay', () async {
    await attach(sink);
    sink.track('session_start');
    sender.outcome = SendOutcome.retry;
    await sink.flush();
    expect(sink.pending, hasLength(1));

    sender.outcome = SendOutcome.sent;
    await sink.flush(); // ещё в backoff — не шлём
    expect(sender.batches, hasLength(1));

    clock = clock.add(BackendEventSink.initialBackoff);
    await sink.flush();
    expect(sender.batches, hasLength(2));
    expect(sink.pending, isEmpty);
  });

  test('backoff grows exponentially and is capped', () async {
    await attach(sink);
    sink.track('session_start');
    sender.outcome = SendOutcome.retry;

    for (var i = 0; i < 8; i++) {
      await sink.flush();
      clock = clock.add(BackendEventSink.maxBackoff);
    }
    expect(sink.retryDelay, BackendEventSink.maxBackoff);
  });

  test('drop outcome removes the batch', () async {
    await attach(sink);
    sink.track('session_start');
    sender.outcome = SendOutcome.drop;
    await sink.flush();
    expect(sink.pending, isEmpty);
  });

  test('queue is capped, oldest events dropped', () async {
    for (var i = 0; i < BackendEventSink.maxQueue + 5; i++) {
      sink.track('screen_view', {'screen': 's$i'});
    }
    expect(sink.pending, hasLength(BackendEventSink.maxQueue));
    expect(sink.pending.first.props['screen'], 's5');
  });

  test('sends in batches of at most maxBatch', () async {
    canSend = false;
    await attach(sink);
    for (var i = 0; i < BackendEventSink.maxBatch + 30; i++) {
      sink.track('screen_view');
    }
    canSend = true;
    await sink.flush();
    expect(sender.batches.map((b) => b.length), [BackendEventSink.maxBatch, 30]);
  });

  test('reaching flushThreshold triggers a flush', () async {
    await attach(sink);
    for (var i = 0; i < BackendEventSink.flushThreshold; i++) {
      sink.track('screen_view');
    }
    await sink.flush(); // дожидаемся уже запущенной отправки
    expect(sender.sentEvents, BackendEventSink.flushThreshold);
  });

  test('periodic timer flushes', () {
    fakeAsync((async) {
      attach(sink);
      async.flushMicrotasks();
      sink.track('session_start');
      async.elapse(BackendEventSink.flushInterval);
      async.flushMicrotasks();
      expect(sender.batches, hasLength(1));
    });
  });

  test('unsupported platform disables the sink', () async {
    sink.track('session_start');
    await attach(sink, platform: null);
    sink.track('session_start');
    expect(sink.pending, isEmpty);
  });

  test('clear wipes queue and storage', () async {
    canSend = false;
    await attach(sink);
    sink.track('session_start');
    await sink.persistNow();
    await sink.clear();

    expect(sink.pending, isEmpty);
    final stored = await db.get(
      key: BackendEventSink.storageKey,
      boxName: LocalDBNames.settings,
    );
    expect(stored == null || (jsonDecode(stored as String) as List).isEmpty, isTrue);
  });
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `flutter test test/unit/backend_event_sink_test.dart`
Expected: FAIL — `Target of URI doesn't exist: ... backend_event_sink.dart`

- [ ] **Step 3: Реализуй sink**

`lib/core/internal/analytics/backend/backend_event_sink.dart`:

```dart
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
  Duration? get retryDelay =>
      _failures == 0 ? null : _backoffFor(_failures);

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
  Future<void> flush() =>
      _inFlight ??= _drain().whenComplete(() => _inFlight = null);

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

  Future<void> _drain() async {
    final sender = _sender;
    final platform = _platform;
    if (sender == null || platform == null) return;
    if (_queue.isEmpty || !_canSend()) return;
    final retryAfter = _retryAfter;
    if (retryAfter != null && _clock().isBefore(retryAfter)) return;

    while (_queue.isNotEmpty && _canSend()) {
      final batch = _queue.take(maxBatch).toList();
      final outcome = await sender([
        for (final e in batch) e.toJson(platform: platform, appVersion: _appVersion),
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
    return [
      for (final e in decoded) ?AnalyticsEvent.fromStorage(e),
    ];
  }
}
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `flutter test test/unit/backend_event_sink_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: Format, analyze, commit**

Run: `dart format lib/core/internal/analytics test/unit && flutter analyze lib/core/internal/analytics`
Expected: `No issues found!`

```bash
git add lib/core/internal/analytics/backend/backend_event_sink.dart test/unit/backend_event_sink_test.dart
git commit -m "feat(analytics): persistent BackendEventSink with batching and backoff"
```

---

### Task 3: Отправка через `ApiClient`

**Files:**
- Modify: `lib/core/internal/network/api_client/api_client.dart` (+ codegen `api_client.g.dart`)
- Create: `lib/core/internal/analytics/backend/api_analytics_sender.dart`
- Test: `test/unit/api_analytics_sender_test.dart`

- [ ] **Step 1: Добавь эндпоинт в `ApiClient`**

В `lib/core/internal/network/api_client/api_client.dart` в конец абстрактного класса (перед закрывающей `}`), отдельной секцией:

```dart
  //! Analytics
  /// Батч клиентских событий. Ответ `202 {"accepted": n, "rejected": m}`
  /// не нужен клиенту — отбрасываем.
  @POST('/analytics/events')
  Future<void> sendAnalyticsEvents({
    @Body() required Map<String, dynamic> body,
  });
```

- [ ] **Step 2: Codegen**

Run: `dart run build_runner build`
Expected: завершается без ошибок; `grep -n "sendAnalyticsEvents" lib/core/internal/network/api_client/api_client.g.dart` находит реализацию.

- [ ] **Step 3: Напиши падающий тест классификации**

`test/unit/api_analytics_sender_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/backend/api_analytics_sender.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';

DioException _http(int status) => DioException(
  requestOptions: RequestOptions(path: '/analytics/events'),
  response: Response(
    requestOptions: RequestOptions(path: '/analytics/events'),
    statusCode: status,
  ),
);

void main() {
  test('success → sent', () async {
    Map<String, dynamic>? sentBody;
    final send = apiAnalyticsSender((body) async => sentBody = body);

    final outcome = await send([
      {'id': '1'},
    ]);

    expect(outcome, SendOutcome.sent);
    expect(sentBody, {
      'events': [
        {'id': '1'},
      ],
    });
  });

  test('error classification', () {
    expect(classifySendError(_http(400)), SendOutcome.drop);
    expect(classifySendError(_http(413)), SendOutcome.drop);
    expect(classifySendError(_http(401)), SendOutcome.retry);
    expect(classifySendError(_http(408)), SendOutcome.retry);
    expect(classifySendError(_http(429)), SendOutcome.retry);
    expect(classifySendError(_http(503)), SendOutcome.retry);
    expect(
      classifySendError(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      ),
      SendOutcome.retry,
    );
    expect(classifySendError(StateError('x')), SendOutcome.retry);
  });
}
```

- [ ] **Step 4: Запусти — должен упасть**

Run: `flutter test test/unit/api_analytics_sender_test.dart`
Expected: FAIL — `Target of URI doesn't exist: ... api_analytics_sender.dart`

- [ ] **Step 5: Реализуй**

`lib/core/internal/analytics/backend/api_analytics_sender.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';

/// Отправка батча через `ApiClient.sendAnalyticsEvents`. [post] принимает
/// тело запроса — так sender тестируется без Dio/DI:
/// `apiAnalyticsSender((body) => api.sendAnalyticsEvents(body: body))`.
AnalyticsBatchSender apiAnalyticsSender(
  Future<void> Function(Map<String, dynamic> body) post,
) {
  return (events) async {
    try {
      await post({'events': events});
      return SendOutcome.sent;
    } catch (error) {
      return classifySendError(error);
    }
  };
}

/// 4xx (кроме 401/408/429) — данные не примут и при повторе → выбросить.
/// Остальное (сеть, таймаут, 5xx, протухший токен) — повторить позже.
SendOutcome classifySendError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null &&
        status >= 400 &&
        status < 500 &&
        status != 401 &&
        status != 408 &&
        status != 429) {
      return SendOutcome.drop;
    }
  }
  return SendOutcome.retry;
}
```

- [ ] **Step 6: Запусти — должен пройти**

Run: `flutter test test/unit/api_analytics_sender_test.dart`
Expected: `All tests passed!`

- [ ] **Step 7: Commit**

```bash
git add lib/core/internal/network/api_client/api_client.dart lib/core/internal/network/api_client/api_client.g.dart \
  lib/core/internal/analytics/backend/api_analytics_sender.dart test/unit/api_analytics_sender_test.dart
git commit -m "feat(analytics): ApiClient analytics endpoint and sender error classification"
```

---

### Task 4: Fan-out в `AnalyticsService` и `session_start`

**Files:**
- Modify: `lib/core/internal/analytics/analytics_service.dart`
- Modify: `lib/core/internal/analytics/usage/usage_tracker.dart` (`sessionStarted`)
- Modify: `lib/core/internal/analytics/usage/usage_session_listener.dart`
- Test: `test/unit/analytics_service_fanout_test.dart`

- [ ] **Step 1: Напиши падающий тест**

`test/unit/analytics_service_fanout_test.dart`:

```dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';

void main() {
  late BackendEventSink backend;
  late UsageTracker usage;
  late AnalyticsService analytics;

  setUp(() {
    backend = BackendEventSink(random: Random(1));
    usage = UsageTracker();
    analytics = AnalyticsService.test(
      usage: usage,
      backend: backend,
      firebaseReady: () => false,
    );
  });

  List<String> sent() => [for (final e in backend.pending) e.name];

  test('domain events stay local — the server records them itself', () async {
    await analytics.logItemAdded(listId: 'l1', section: 'Овощи');
    await analytics.logItemMarkedBought(name: 'Томаты');
    await analytics.logItemDeleted();
    await analytics.logListCreated(shared: true);
    await analytics.logListOpened('l1');

    expect(sent(), isEmpty);
  });

  test('client-only events go to backend with whitelisted props', () async {
    await analytics.logSessionStart();
    await analytics.logScreenView('InsightsRoute');
    await analytics.logScreenView('HomeRoute', countVisit: false);
    await analytics.logAiChatOpened();
    await analytics.logAiMessageSent();
    await analytics.logTipGenerated(fromFallback: true);
    await analytics.logRecipeImport(source: 'youtube', host: 'youtube.com');
    await analytics.logSupportMessageSent();
    await analytics.logViewModeChanged(grid: true);

    expect(sent(), [
      'session_start',
      'screen_view',
      'ai_chat_opened',
      'ai_message_sent',
      'ai_tip_generated',
      'recipe_import',
      'support_message_sent',
      'view_mode_changed',
    ]);
    expect(backend.pending[1].props, {'screen': 'InsightsRoute'});
    expect(backend.pending[5].props, {'source': 'youtube'});
    expect(backend.pending[7].props, {'grid': true});
  });
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `flutter test test/unit/analytics_service_fanout_test.dart`
Expected: FAIL — `The method 'test' isn't defined for the type 'AnalyticsService'` / `logSessionStart` не определён.

- [ ] **Step 3: Обнови `AnalyticsService`**

В `lib/core/internal/analytics/analytics_service.dart`:

1) Импорты — добавь:

```dart
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
```

2) Замени шапку класса (от doc-комментария до геттера `_analytics` включительно) на:

```dart
/// Единая точка аналитики. Типизированные события раздаются в три приёмника:
/// - Firebase Analytics (агрегаты по всем юзерам, DebugView);
/// - локальный [UsageTracker] (персональная статистика на экране Insights);
/// - [BackendEventSink] → `POST /api/analytics/events` (админ-панель).
///
/// В backend идут только client-only события (сессии, экраны, AI, рецепты,
/// поддержка, режим отображения). Доменные (товар/список) пишет сервер —
/// здесь их в backend не шлём, иначе двойной счёт.
///
/// Firebase поднимается отложенно (AppBootstrap) — до этого Firebase-часть
/// no-op'ит, а локальный трекер и backend-очередь копят события в буфере.
class AnalyticsService {
  AnalyticsService._()
    : _usageOverride = null,
      _backendOverride = null,
      _firebaseReady = _defaultFirebaseReady;

  @visibleForTesting
  AnalyticsService.test({
    required UsageTracker usage,
    required BackendEventSink backend,
    required bool Function() firebaseReady,
  }) : _usageOverride = usage,
       _backendOverride = backend,
       _firebaseReady = firebaseReady;

  static final AnalyticsService instance = AnalyticsService._();

  final UsageTracker? _usageOverride;
  final BackendEventSink? _backendOverride;
  final bool Function() _firebaseReady;

  static bool _defaultFirebaseReady() => Firebase.apps.isNotEmpty;

  UsageTracker get _usage => _usageOverride ?? UsageTracker.instance;

  BackendEventSink get _backend => _backendOverride ?? BackendEventSink.instance;

  bool get _ready => _firebaseReady();

  FirebaseAnalytics? get _analytics =>
      _ready ? FirebaseAnalytics.instance : null;
```

3) В `logScreenView` замени строку `if (countVisit) _usage.screenViewed(screenName);` на:

```dart
    if (countVisit) {
      _usage.screenViewed(screenName);
      _backend.track('screen_view', {'screen': screenName});
    }
```

4) Перед секцией `//! --- Типизированные события домена ---` добавь:

```dart
  /// Начало сессии (холодный старт или возврат из фона). Firebase-аналог —
  /// `logAppOpen` в [init]; здесь — только backend.
  Future<void> logSessionStart() async {
    _backend.track('session_start');
  }
```

5) Добавь `_backend.track(...)` в client-only методы (остальное тело метода не меняй):

```dart
  Future<void> logAiChatOpened() {
    _backend.track('ai_chat_opened');
    return _log('ai_chat_opened');
  }

  Future<void> logAiMessageSent() {
    _usage.aiMessageSent();
    _backend.track('ai_message_sent');
    return _log('ai_message_sent');
  }

  Future<void> logTipGenerated({required bool fromFallback}) {
    _backend.track('ai_tip_generated');
    return _log('ai_tip_generated', {'fallback': fromFallback.toString()});
  }
```

в `logRecipeImport({...})` после `_usage.recipeImported();`:

```dart
    _backend.track('recipe_import', {'source': source});
```

```dart
  Future<void> logSupportMessageSent() {
    _backend.track('support_message_sent');
    return _log('support_message_sent');
  }

  Future<void> logViewModeChanged({required bool grid}) {
    _backend.track('view_mode_changed', {'grid': grid});
    return _log('home_view_mode', {'grid': grid.toString()});
  }
```

Доменные методы (`logListOpened`, `logListCreated`, `logItemAdded`, `logItemMarkedBought`, `logItemDeleted`) и остальные (`logAiResponse`, `logRecipeImportFailed`, `logRecipeItemsAdded`, `logInsightsPeriodChanged`, `logAiConfigSaved`) **не трогай** — в backend они не идут (сервер либо пишет их сам, либо их нет в whitelist).

- [ ] **Step 4: `sessionStarted()` сообщает о новой сессии**

В `lib/core/internal/analytics/usage/usage_tracker.dart` замени метод `sessionStarted`:

```dart
  /// Начало сессии (холодный старт или возврат из фона).
  /// Повторный вызов в рамках живой сессии (inactive → resumed) игнорируется.
  /// Возвращает `true`, если началась новая сессия.
  bool sessionStarted() {
    if (_sessionStart != null) return false;
    _sessionStart = _clock();
    _record((d) => d.copyWith(opens: d.opens + 1), hour: true);
    return true;
  }
```

- [ ] **Step 5: Listener шлёт `session_start` и сбрасывает очередь при уходе в фон**

Замени содержимое `lib/core/internal/analytics/usage/usage_session_listener.dart`:

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';

/// Связывает lifecycle приложения с сессиями [UsageTracker] и backend-очередью:
/// `resumed` → старт сессии (+ `session_start` на бэкенд),
/// `hidden`/`paused`/`detached` → конец сессии, flush трекера и очереди.
/// `inactive` (шторка, системный диалог) сессию не рвёт.
class UsageSessionListener {
  UsageSessionListener._();

  static AppLifecycleListener? _listener;

  /// Идемпотентно. Требует инициализированный `WidgetsBinding`.
  static void start([UsageTracker? tracker]) {
    if (_listener != null) return;
    final t = tracker ?? UsageTracker.instance;

    void begin() {
      if (t.sessionStarted()) {
        unawaited(AnalyticsService.instance.logSessionStart());
      }
    }

    begin();
    _listener = AppLifecycleListener(
      onStateChange: (state) {
        switch (state) {
          case AppLifecycleState.resumed:
            begin();
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
          case AppLifecycleState.detached:
            t.sessionEnded();
            unawaited(BackendEventSink.instance.flush());
          case AppLifecycleState.inactive:
            break;
        }
      },
    );
  }
}
```

- [ ] **Step 6: Тесты**

Run: `flutter test test/unit/analytics_service_fanout_test.dart test/unit/usage_tracker_test.dart`
Expected: `All tests passed!`

Если какой-то вызов `logTipGenerated(...)` / `logRecipeImport(...)` в `lib/` перестал компилироваться — значит сигнатура отличается от Предусловия; приведи тело метода в соответствие, вызовы не меняй.

- [ ] **Step 7: Analyze и commit**

Run: `dart format lib test && flutter analyze lib/core/internal/analytics`
Expected: `No issues found!`

```bash
git add lib/core/internal/analytics/analytics_service.dart lib/core/internal/analytics/usage/usage_tracker.dart \
  lib/core/internal/analytics/usage/usage_session_listener.dart test/unit/analytics_service_fanout_test.dart
git commit -m "feat(analytics): fan out client-only events to backend sink; session_start"
```

---

### Task 5: Подключение sink в bootstrap и logout

**Files:**
- Modify: `pubspec.yaml` (через `flutter pub add`)
- Modify: `lib/core/internal/bootstrap/app_bootstrap.dart`
- Modify: `lib/core/features/settings/presentation/store/settings_store.dart`

- [ ] **Step 1: Зависимость `package_info_plus`**

Run: `flutter pub add package_info_plus`
Expected: строка `package_info_plus: ^<версия>` в `dependencies` `pubspec.yaml`, `pub get` без конфликтов. Если резолвер ругается на конфликт — остановись и сообщи (не форсируй `dependency_overrides`).

- [ ] **Step 2: Attach в `AppBootstrap`**

В `lib/core/internal/bootstrap/app_bootstrap.dart`:

импорты:

```dart
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pora/core/internal/analytics/backend/api_analytics_sender.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
```

(существующий `import 'package:flutter/foundation.dart' show kDebugMode;` объедини: `show defaultTargetPlatform, kDebugMode, TargetPlatform;`).

В `_run` сразу после блока

```dart
      unawaited(
        UsageTracker.instance.attach(container.getIt<ILocalDB<dynamic>>()),
      );
```

добавь:

```dart
      // Клиентские события → бэкенд (админ-панель аналитики).
      unawaited(_attachAnalyticsSink(container));
```

Добавь методы в класс (после `_bindOutboxToConnectivity`):

```dart
  /// Очередь клиентских событий: шлём только авторизованным и онлайн;
  /// дополнительно сбрасываем её при логине и при появлении сети.
  Future<void> _attachAnalyticsSink(InjectionContainer container) async {
    try {
      final auth = container.getIt<AuthState>();
      final connectivity = container.getIt<ConnectivityStore>();
      final api = container.getIt<ApiClient>();
      final info = await PackageInfo.fromPlatform();
      final sink = BackendEventSink.instance;

      await sink.attach(
        db: container.getIt<ILocalDB<dynamic>>(),
        sender: apiAnalyticsSender(
          (body) => api.sendAnalyticsEvents(body: body),
        ),
        canSend: () => auth.isAuthenticated && connectivity.online,
        platform: _analyticsPlatform(),
        appVersion: info.version,
      );

      // Подписки живут весь lifecycle приложения (singleton не диспоузится).
      auth.stream
          .where((status) => status == AuthStatus.authenticated)
          .listen((_) => unawaited(sink.flush()));
      reaction<bool>((_) => connectivity.online, (online) {
        if (online) unawaited(sink.flush());
      });
    } catch (e, s) {
      Logger.talker.warning('Analytics sink attach failed', e, s);
    }
  }

  /// Бэкенд принимает события только с мобильных платформ.
  static String? _analyticsPlatform() => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    _ => null,
  };
```

Если `AuthState`/`AuthStatus`/`ApiClient` не экспортируются через `di/export.dart` — добавь прямые импорты `package:pora/core/internal/router/guard/auth_state.dart` и `package:pora/core/internal/network/api_client/api_client.dart` (проверь `flutter analyze`).

- [ ] **Step 3: Logout — flush до инвалидации токена, clear после**

В `lib/core/features/settings/presentation/store/settings_store.dart`, метод `logout()`, замени тело на:

```dart
  @action
  Future<void> logout() async {
    // Пока токен жив — отправляем накопленные события текущего юзера.
    await BackendEventSink.instance.flush();
    await GetIt.I<LogoutUseCase>().call();
    final tokensStore = GetIt.I<TokensSecureStore>();
    await tokensStore.clearTokens();
    // Чистим весь offline-cache — новый юзер не должен видеть чужие снапшоты.
    await HiveJsonCache.clear();
    await UsageTracker.instance.clear();
    await BackendEventSink.instance.clear();
    GetIt.I<AuthState>().setUnauthenticated();
  }
```

и импорт `package:pora/core/internal/analytics/backend/backend_event_sink.dart`.

- [ ] **Step 4: Format, analyze, тесты**

Run:

```bash
dart format lib test
flutter analyze lib/core/internal lib/core/features/settings
flutter test --exclude-tags golden
```

Expected: `No issues found!`, все тесты зелёные. Если analyze ругается на `cancel_subscriptions` для `auth.stream...listen` — сохрани подписку в поле `StreamSubscription<AuthStatus>? _authFlushSub;` класса `AppBootstrap` (`_authFlushSub ??= ...`), не глуши линт.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/internal/bootstrap/app_bootstrap.dart \
  lib/core/features/settings/presentation/store/settings_store.dart
git commit -m "feat(analytics): attach backend sink in bootstrap; flush/clear on logout"
```

---

### Task 6: Ручная проверка end-to-end (нужен бэкенд с планом 1)

**Files:** нет изменений.

- [ ] **Step 1: Подними бэкенд и приложение**

```bash
docker compose -f backend/docker-compose.yml up -d --build
flutter run -d ios
```

(`API_URL` в `.env` приложения должен указывать на локальный бэкенд; для iOS-симулятора `http://localhost:5040/api`.)

- [ ] **Step 2: Сгенерируй события**

В приложении: свернуть/развернуть (session_start), открыть Insights (screen_view), открыть AI-чат и отправить сообщение, переключить вид home grid/list. Затем свернуть приложение (flush).

- [ ] **Step 3: Проверь таблицу**

```bash
docker compose -f backend/docker-compose.yml exec postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT name, props, platform, app_version, source FROM analytics_events WHERE source = '"'"'client'"'"' ORDER BY occurred_at DESC LIMIT 10"'
```

Expected: строки `session_start`, `screen_view {"screen": ...}`, `ai_chat_opened`, `ai_message_sent`, `view_mode_changed {"grid": ...}` с `platform=ios`, непустой `app_version`, `source=client`; **нет** клиентских `item_added`/`item_bought`. Повторный flush (свернуть ещё раз) не создаёт дублей.

- [ ] **Step 4: Offline**

Выключи сеть на машине/симуляторе, сгенерируй 2–3 события, сверни приложение, включи сеть, разверни. Через ≤30 с события появляются в таблице.

---

### Task 7: `pickChampion` и `@computed champion` в `StatisticsStore`

**Files:**
- Modify: `lib/core/features/insights/presentation/store/statistics_store.dart` (+ codegen `statistics_store.g.dart`)
- Test: `test/unit/statistics_champion_test.dart`

- [ ] **Step 1: Напиши падающий тест**

`test/unit/statistics_champion_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';

PopularProductEntity _popular(String name, int quantity) => PopularProductEntity(
  name: name,
  quantity: quantity,
  howOftenEnds: 0,
  currentDay: 0,
);

void main() {
  test('server top wins when it has purchases', () {
    final champion = pickChampion(
      [_popular('Молоко', 12)],
      const [CountEntry('Хлеб', 3)],
    );
    expect(champion?.name, 'Молоко');
    expect(champion?.count, 12);
  });

  test('falls back to local top when server is empty or zero', () {
    expect(
      pickChampion([_popular('Молоко', 0)], const [CountEntry('Хлеб', 3)])?.name,
      'Хлеб',
    );
    expect(pickChampion(const [], const [CountEntry('Хлеб', 3)])?.count, 3);
  });

  test('null when nothing is known', () {
    expect(pickChampion(const [], const []), isNull);
  });
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `flutter test test/unit/statistics_champion_test.dart`
Expected: FAIL — `Method not found: 'pickChampion'`

- [ ] **Step 3: Реализуй**

В `lib/core/features/insights/presentation/store/statistics_store.dart` после `const insightsPeriods = [7, 30, 90];`:

```dart
/// «Чемпион» покупок: сервер видит покупки со всех устройств, локальный
/// топ — запасной вариант. `null` — показывать нечего.
CountEntry? pickChampion(
  List<PopularProductEntity> server,
  List<CountEntry> local,
) {
  if (server.isNotEmpty && server.first.quantity > 0) {
    return CountEntry(server.first.name, server.first.quantity);
  }
  if (local.isNotEmpty) return local.first;
  return null;
}
```

В классе `_StatisticsStoreBase` рядом с другими `@computed` (после `urgentCount`):

```dart
  @computed
  CountEntry? get champion =>
      pickChampion(popularProducts.toList(), usage.topBought);
```

- [ ] **Step 4: Codegen и тест**

Run:

```bash
dart run build_runner build
flutter test test/unit/statistics_champion_test.dart
```

Expected: codegen без ошибок; `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/features/insights/presentation/store/statistics_store.dart \
  lib/core/features/insights/presentation/store/statistics_store.g.dart test/unit/statistics_champion_test.dart
git commit -m "refactor(insights): champion selection as pure function + computed"
```

---

### Task 8: Секции Insights как отдельные виджеты

**Files:**
- Create: `lib/core/features/insights/presentation/widgets/sections/insights_header.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/kpi_grid.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/due_soon_section.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/champion_section.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/top_bought_section.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/categories_section.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/engagement_section.dart`
- Create: `lib/core/features/insights/presentation/widgets/sections/popular_section.dart`
- Test: `test/widget/insights_sections_test.dart`

Код секций — перенос приватных классов из `insights_screen.dart` с одним изменением: на вход данные, а не `StatisticsStore`.

- [ ] **Step 1: Напиши падающие виджет-тесты**

`test/widget/insights_sections_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/categories_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/champion_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/insights_header.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/popular_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/top_bought_section.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: PoraTheme.light,
  locale: const Locale('ru'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

PopularProductEntity _popular(String name, int quantity) => PopularProductEntity(
  name: name,
  quantity: quantity,
  howOftenEnds: 0,
  currentDay: 0,
);

void main() {
  testWidgets('empty sections collapse', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ChampionSection(champion: null),
            TopBoughtSection(top: [CountEntry('Хлеб', 1)]),
            CategoriesSection(categories: []),
          ],
        ),
      ),
    );
    expect(find.byType(SizedBox), findsWidgets);
    expect(find.text('Хлеб'), findsNothing);
  });

  testWidgets('champion and top bought render names', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ChampionSection(champion: CountEntry('Молоко', 12)),
            TopBoughtSection(
              top: [CountEntry('Хлеб', 4), CountEntry('Сыр', 2)],
            ),
          ],
        ),
      ),
    );
    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('Хлеб'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
  });

  testWidgets('popular section: loading, error, list', (tester) async {
    await tester.pumpWidget(
      _wrap(const PopularSection(products: [], isLoading: true, errorMessage: null)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _wrap(const PopularSection(products: [], isLoading: false, errorMessage: 'Нет сети')),
    );
    expect(find.text('Нет сети'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        PopularSection(
          products: [_popular('Молоко', 5)],
          isLoading: false,
          errorMessage: null,
        ),
      ),
    );
    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('×5'), findsOneWidget);
  });

  testWidgets('header back button fires callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(InsightsHeader(title: 'Инсайты', onBack: () => tapped = true)),
    );
    await tester.tap(find.byType(GestureDetector).first);
    expect(tapped, isTrue);
    expect(find.text('Инсайты'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `flutter test test/widget/insights_sections_test.dart`
Expected: FAIL — `Target of URI doesn't exist: ... sections/categories_section.dart`

- [ ] **Step 3: `insights_header.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';

/// Заголовок экрана Insights с кнопкой «назад».
class InsightsHeader extends StatelessWidget {
  const InsightsHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: MaterialLocalizations.of(context).backButtonTooltip,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Icon(PhosphorIconsRegular.caretLeft, size: 26),
            ),
          ),
        ),
        const SizedBox(width: PoraSpacing.md),
        Text(title, style: PoraText.title),
      ],
    );
  }
}
```

- [ ] **Step 4: `kpi_grid.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/stat_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

/// 2×N сетка ключевых метрик периода с трендом к прошлому периоду.
class InsightsKpiGrid extends StatelessWidget {
  const InsightsKpiGrid({super.key, required this.summary});

  final UsageSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = summary;
    final rate = s.completionRate;
    final avg = s.avgSessionMinutes;
    Widget row(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: PoraSpacing.md),
        Expanded(child: b),
      ],
    );
    return Column(
      children: [
        row(
          StatCard(
            number: '${s.added}',
            label: l.insightsKpiAdded,
            delta: UsageSummary.deltaPercent(s.added, s.prevAdded),
          ),
          StatCard(
            number: '${s.bought}',
            label: l.insightsKpiBought,
            delta: UsageSummary.deltaPercent(s.bought, s.prevBought),
          ),
        ),
        const SizedBox(height: PoraSpacing.md),
        row(
          StatCard(
            number: rate == null ? '—' : '${(rate * 100).round()}%',
            label: l.insightsKpiCompletion,
          ),
          StatCard(
            number: '${s.activeDays}/${s.periodDays}',
            label: l.insightsKpiActiveDays,
            delta: UsageSummary.deltaPercent(s.activeDays, s.prevActiveDays),
          ),
        ),
        const SizedBox(height: PoraSpacing.md),
        row(
          StatCard(number: '${s.minutes}', label: l.insightsKpiMinutes),
          StatCard(
            number: '${s.opens}',
            label: l.insightsKpiSessions,
            hint: avg == null || avg < 0.1
                ? null
                : l.insightsAvgSession(avg.toStringAsFixed(avg < 10 ? 1 : 0)),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: `due_soon_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/due_soon_card.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// «Скоро закончится» — пустой список скрывает секцию.
class DueSoonSection extends StatelessWidget {
  const DueSoonSection({super.key, required this.items});

  final List<PopularProductEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(context.l10n.insightsDueSoonTitle),
          DueSoonCard(items: items),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: `champion_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/champion_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

/// Самый покупаемый товар (см. `pickChampion`); null скрывает секцию.
class ChampionSection extends StatelessWidget {
  const ChampionSection({super.key, required this.champion});

  final CountEntry? champion;

  @override
  Widget build(BuildContext context) {
    final c = champion;
    if (c == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.lg),
      child: ChampionCard(name: c.name, count: c.count),
    );
  }
}
```

- [ ] **Step 7: `top_bought_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Топ-5 локальных покупок; меньше двух позиций — секция скрыта.
class TopBoughtSection extends StatelessWidget {
  const TopBoughtSection({super.key, required this.top});

  final List<CountEntry> top;

  @override
  Widget build(BuildContext context) {
    if (top.length < 2) return const SizedBox.shrink();
    final max = top.first.count;
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(context.l10n.insightsTopBoughtTitle),
          PoraRowsCard(
            children: [
              for (final e in top.take(5))
                FrequencyRow(
                  name: e.name,
                  sub: '×${e.count}',
                  pct: max == 0 ? 0 : e.count / max,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 8: `categories_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/category_bars.dart';
import 'package:pora/core/features/insights/presentation/widgets/insight_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

/// Доли категорий добавленных товаров; пусто — секция скрыта.
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key, required this.categories});

  final List<CountEntry> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final total = categories.fold<int>(0, (a, e) => a + e.count);
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.lg),
      child: InsightCard(
        title: context.l10n.insightsCategoriesTitle,
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.lg,
          PoraSpacing.lg,
          PoraSpacing.lg,
          PoraSpacing.sm,
        ),
        child: CategoryBars(
          items: [
            for (final c in categories)
              CategoryBar(
                name: c.name,
                share: total == 0 ? 0 : c.count / total,
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 9: `engagement_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/insights/presentation/widgets/metric_tiles.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Вовлечённость за период + счётчики «за всё время» с сервера.
class EngagementSection extends StatelessWidget {
  const EngagementSection({
    super.key,
    required this.summary,
    required this.uniqueProducts,
    required this.remindersCount,
    required this.urgentCount,
  });

  final UsageSummary summary;
  final int uniqueProducts;
  final int remindersCount;
  final int urgentCount;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricTiles(
          tiles: [
            MetricTile(
              icon: PhosphorIconsRegular.listChecks,
              value: '${s.listsOpened}',
              label: l.insightsKpiListsOpened,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.plus,
              value: '${s.listsCreated}',
              label: l.insightsKpiListsCreated,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.cookingPot,
              value: '${s.recipes}',
              label: l.insightsKpiRecipes,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.chatCircleDots,
              value: '${s.aiMessages}',
              label: l.insightsKpiAi,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.trash,
              value: '${s.deleted}',
              label: l.insightsKpiDeleted,
            ),
          ],
        ),
        const SizedBox(height: PoraSpacing.xl),
        SectionLabel(l.insightsAllTimeTitle),
        MetricTiles(
          tiles: [
            MetricTile(
              icon: PhosphorIconsRegular.package,
              value: '$uniqueProducts',
              label: l.insightsStatsProducts,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.bellRinging,
              value: '$remindersCount',
              label: l.insightsKpiReminders,
            ),
            MetricTile(
              icon: PhosphorIconsRegular.warning,
              value: '$urgentCount',
              label: l.insightsKpiUrgent,
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 10: `popular_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';

/// Популярные товары с сервера: загрузка / ошибка-или-пусто / список.
class PopularSection extends StatelessWidget {
  const PopularSection({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<PopularProductEntity> products;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: PoraSpacing.lg),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.md),
        child: Text(
          errorMessage ?? context.l10n.insightsEmpty,
          style: PoraText.small.copyWith(color: context.colors.textSubtle),
          textAlign: TextAlign.center,
        ),
      );
    }
    final l = context.l10n;
    final top = products.first.quantity;
    return PoraRowsCard(
      children: [
        for (final p in products.take(6))
          FrequencyRow(
            name: p.name,
            sub: p.howOftenEnds > 0
                ? l.insightsFreqEvery(p.howOftenEnds)
                : '×${p.quantity}',
            pct: top == 0 ? 0 : p.quantity / top,
          ),
      ],
    );
  }
}
```

- [ ] **Step 11: Запусти тесты секций**

Run: `flutter test test/widget/insights_sections_test.dart`
Expected: `All tests passed!` Если `find.byType(GestureDetector).first` попадает не в кнопку «назад» — замени на `find.byIcon(PhosphorIconsRegular.caretLeft)` (импорт `phosphoricons_flutter`).

- [ ] **Step 12: Commit**

```bash
git add lib/core/features/insights/presentation/widgets/sections test/widget/insights_sections_test.dart
git commit -m "refactor(insights): extract screen sections into data-driven widgets"
```

---

### Task 9: Экран Insights — только композиция

**Files:**
- Modify: `lib/core/features/insights/presentation/screen/insights_screen.dart`

- [ ] **Step 1: Замени файл целиком**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/insights/presentation/widgets/activity_chart.dart';
import 'package:pora/core/features/insights/presentation/widgets/period_switch.dart';
import 'package:pora/core/features/insights/presentation/widgets/rhythm_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/categories_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/champion_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/due_soon_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/engagement_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/insights_header.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/kpi_grid.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/popular_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/top_bought_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/streak_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/weekly_heatmap.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/responsive.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Инсайты: локальная статистика пользования (`UsageTracker`) за выбранный
/// период + серверная статистика продуктов (`StatisticsStore`).
///
/// Каждый блок — свой `Observer` вокруг data-виджета из `widgets/sections/`:
/// смена периода/новое событие перерисовывает только зависящие секции.
@RoutePage()
class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final StatisticsStore _store = GetIt.I<StatisticsStore>();

  @override
  void initState() {
    super.initState();
    _store.loadAll();
  }

  void _setPeriod(int days) {
    if (days == _store.period) return;
    _store.setPeriod(days);
    AnalyticsService.instance.logInsightsPeriodChanged(days);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    var step = 0;
    // Каскад появления: каждая следующая секция чуть позже.
    Widget fade(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 40 + 40 * step++),
      child: child,
    );
    const gap = SizedBox(height: PoraSpacing.lg);
    const sectionGap = SizedBox(height: PoraSpacing.xl);

    return Scaffold(
      body: SafeArea(
        child: AdaptiveContainer(
          child: RefreshIndicator.adaptive(
            onRefresh: () => _store.loadAll(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                6,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              children: [
                fade(
                  InsightsHeader(
                    title: l.insightsTitle,
                    onBack: () => context.router.maybePop(),
                  ),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) => PeriodSwitch(
                      periods: insightsPeriods,
                      value: _store.period,
                      onChanged: _setPeriod,
                    ),
                  ),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) => StreakCard(
                      days: _store.usage.currentStreak,
                      best: _store.usage.bestStreak,
                    ),
                  ),
                ),
                const SizedBox(height: PoraSpacing.md),
                fade(
                  Observer(
                    builder: (_) => InsightsKpiGrid(summary: _store.usage),
                  ),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) => ActivityChart(points: _store.usage.series),
                  ),
                ),
                gap,
                fade(
                  Observer(builder: (_) => RhythmCard(summary: _store.usage)),
                ),
                gap,
                fade(
                  Observer(
                    builder: (_) =>
                        WeeklyHeatmap(activity: _store.usage.activityByDay),
                  ),
                ),
                fade(
                  Observer(builder: (_) => DueSoonSection(items: _store.dueSoon)),
                ),
                fade(
                  Observer(
                    builder: (_) => ChampionSection(champion: _store.champion),
                  ),
                ),
                fade(
                  Observer(
                    builder: (_) => TopBoughtSection(top: _store.usage.topBought),
                  ),
                ),
                fade(
                  Observer(
                    builder: (_) =>
                        CategoriesSection(categories: _store.categories),
                  ),
                ),
                sectionGap,
                fade(SectionLabel(l.insightsEngagementTitle)),
                fade(
                  Observer(
                    builder: (_) => EngagementSection(
                      summary: _store.usage,
                      uniqueProducts: _store.uniqueProducts,
                      remindersCount: _store.remindersCount,
                      urgentCount: _store.urgentCount,
                    ),
                  ),
                ),
                sectionGap,
                fade(SectionLabel(l.insightsPopular)),
                fade(
                  Observer(
                    builder: (_) => PopularSection(
                      products: _store.popularProducts.toList(),
                      isLoading: _store.isPopularLoading,
                      errorMessage: _store.popularError,
                    ),
                  ),
                ),
                sectionGap,
                fade(
                  Text(
                    l.insightsLocalNote,
                    textAlign: TextAlign.center,
                    style: PoraText.micro.copyWith(
                      color: context.colors.textSubtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Нет ли мёртвых двойников**

Run: `grep -rn "_KpiGrid\|_DueSoonSection\|_ChampionSection\|_TopBoughtSection\|_CategoriesSection\|_Engagement\|_PopularList\|class _Header" lib/core/features/insights`
Expected: пусто.

- [ ] **Step 3: Format, analyze, все тесты**

```bash
dart format lib test
flutter analyze
flutter test --exclude-tags golden
```

Expected: `No issues found!`; все тесты зелёные (включая существующие `insights_widgets_test.dart`, `usage_tracker_test.dart`).

- [ ] **Step 4: Визуальная проверка**

`flutter run -d ios`, открой Insights: экран выглядит и ведёт себя как до рефакторинга (переключение периода, pull-to-refresh, пустые секции скрыты). Строк в файле экрана: `wc -l lib/core/features/insights/presentation/screen/insights_screen.dart` → около 190 (было 481).

- [ ] **Step 5: Commit**

```bash
git add lib/core/features/insights/presentation/screen/insights_screen.dart
git commit -m "refactor(insights): screen composes section widgets only"
```

---

## Проверка плана целиком

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test --exclude-tags golden
```

Expected: как в CI (`ci.yml` job `quality`) — всё зелёное.
