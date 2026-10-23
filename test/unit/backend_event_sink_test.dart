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

  test(
    'events before attach are kept and sent with platform/version',
    () async {
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
    },
  );

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
    expect(sender.batches.map((b) => b.length), [
      BackendEventSink.maxBatch,
      30,
    ]);
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
    expect(
      stored == null || (jsonDecode(stored as String) as List).isEmpty,
      isTrue,
    );
  });
}
