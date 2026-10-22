import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_replayer.dart';

void main() {
  late Directory tmp;
  late Outbox outbox;
  late OutboxReplayer replayer;
  late List<Duration> scheduled;
  var online = true;
  var clockShift = Duration.zero;

  OutboxReplayer build() => OutboxReplayer(
    outbox: outbox,
    isOnline: () => online,
    now: () => DateTime.now().add(clockShift),
    timerFactory: (delay, _) {
      scheduled.add(delay);
      // Не стреляет в рамках теста; отменяется в dispose().
      return Timer(const Duration(days: 1), () {});
    },
  );

  Future<Either<Failure, Object?>> ok(Map<String, dynamic> _) async =>
      Right(const ServerSuccess());
  Future<Either<Failure, Object?>> offline(Map<String, dynamic> _) async =>
      Left(const NetworkFailure());
  Future<Either<Failure, Object?>> rejected(Map<String, dynamic> _) async =>
      Left(const ValidationFailure('bad'));

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_outbox_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-outbox');
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    outbox = Outbox();
    await outbox.clear();
    scheduled = [];
    online = true;
    clockShift = Duration.zero;
    replayer = build();
  });

  tearDown(() async {
    await replayer.dispose();
    await outbox.dispose();
  });

  test('successful handlers drain the queue and report replayed', () async {
    await outbox.enqueue('a', {'n': 1});
    await outbox.enqueue('a', {'n': 2});
    replayer.register('a', ok);

    final outcome = await replayer.flush();

    expect(outcome.replayed, 2);
    expect(outcome.paused, isFalse);
    expect(await outbox.length, 0);
    expect(scheduled, isEmpty);
  });

  test(
    'connectivity failure pauses, keeps entry, schedules 5s retry',
    () async {
      await outbox.enqueue('a', {});
      replayer.register('a', offline);

      final outcome = await replayer.flush();

      expect(outcome.paused, isTrue);
      expect(await outbox.length, 1);
      expect(scheduled, [const Duration(seconds: 5)]);
    },
  );

  test('backoff doubles up to 1 minute and resets on success', () async {
    await outbox.enqueue('a', {});
    replayer.register('a', offline);

    final seen = <Duration?>[];
    for (var i = 0; i < 8; i++) {
      await replayer.flush();
      seen.add(replayer.currentBackoff);
    }
    expect(seen, [
      const Duration(seconds: 5),
      const Duration(seconds: 10),
      const Duration(seconds: 20),
      const Duration(seconds: 40),
      const Duration(minutes: 1),
      const Duration(minutes: 1),
      const Duration(minutes: 1),
      const Duration(minutes: 1),
    ]);

    replayer.register('a', ok);
    await replayer.flush();
    expect(replayer.currentBackoff, isNull);
  });

  test(
    'paused while device offline → no timer (connectivity reaction will flush)',
    () async {
      online = false;
      await outbox.enqueue('a', {});
      replayer.register('a', offline);

      await replayer.flush();

      expect(scheduled, isEmpty);
    },
  );

  test('permanent failure drops entry and reports it', () async {
    await outbox.enqueue('a', {'item-id': 'i1'});
    replayer.register('a', rejected);

    final outcome = await replayer.flush();

    expect(await outbox.length, 0);
    expect(outcome.dropped.single.args['item-id'], 'i1');
  });

  test('entries older than TTL are dropped without calling handler', () async {
    await outbox.enqueue('a', {});
    var calls = 0;
    replayer.register('a', (_) async {
      calls++;
      return Right(const ServerSuccess());
    });
    clockShift = const Duration(days: 8);

    final outcome = await replayer.flush();

    expect(calls, 0);
    expect(outcome.dropped, hasLength(1));
    expect(await outbox.length, 0);
  });

  test('unknown kind is dropped silently (not user-visible)', () async {
    await outbox.enqueue('unregistered', {});

    final outcome = await replayer.flush();

    expect(await outbox.length, 0);
    expect(outcome.dropped, isEmpty);
  });

  test('events emit only when something was replayed or dropped', () async {
    final got = <FlushOutcome>[];
    final sub = replayer.events.listen(got.add);
    addTearDown(sub.cancel);

    await replayer.flush(); // пустая очередь
    await Future<void>.delayed(Duration.zero);
    expect(got, isEmpty);

    await outbox.enqueue('a', {});
    replayer.register('a', ok);
    await replayer.flush();
    await Future<void>.delayed(Duration.zero);
    expect(got.single.replayed, 1);
  });

  test('scheduleFlush keeps the earlier timer', () {
    replayer.scheduleFlush(const Duration(seconds: 10));
    replayer.scheduleFlush(const Duration(seconds: 20)); // позже — no-op
    replayer.scheduleFlush(const Duration(seconds: 3)); // раньше — replace
    expect(scheduled, [
      const Duration(seconds: 10),
      const Duration(seconds: 3),
    ]);
  });

  test('start(): enqueue while online schedules flush after 3s', () async {
    replayer.start();
    await outbox.enqueue('a', {});
    await Future<void>.delayed(Duration.zero);
    expect(scheduled, [OutboxReplayer.enqueueDelay]);
  });

  test('start(): enqueue while offline schedules nothing', () async {
    online = false;
    replayer.start();
    await outbox.enqueue('a', {});
    await Future<void>.delayed(Duration.zero);
    expect(scheduled, isEmpty);
  });

  test(
    'flush during a running flush is skipped and re-run afterwards',
    () async {
      await outbox.enqueue('a', {});
      final gate = Completer<void>();
      replayer.register('a', (_) async {
        await gate.future;
        return Right(const ServerSuccess());
      });

      final first = replayer.flush();
      final second = await replayer.flush();
      expect(second.wasSkipped, isTrue);
      expect(second.hasChanges, isFalse);

      gate.complete();
      final outcome = await first;
      expect(outcome.wasSkipped, isFalse);
      expect(scheduled, contains(Duration.zero));
    },
  );

  test('no re-run is scheduled when nothing was skipped', () async {
    await outbox.enqueue('a', {});
    replayer.register('a', ok);
    await replayer.flush();
    expect(scheduled, isEmpty);
  });

  test(
    'entry coalesced away mid-flush is neither replayed nor resurrected',
    () async {
      await outbox.enqueue('a', {});
      await outbox.enqueue('b', {});
      var bCalls = 0;
      replayer.register('a', (_) async {
        await outbox.removeWhere((e) => e.kind == 'b');
        return Right(const ServerSuccess());
      });
      replayer.register('b', (_) async {
        bCalls++;
        return Right(const ServerSuccess());
      });

      final outcome = await replayer.flush();

      expect(bCalls, 0);
      expect(outcome.replayed, 1);
      expect(await outbox.length, 0);
    },
  );

  test(
    'throwing handler drops only its entry and the rest is replayed',
    () async {
      await outbox.enqueue('boom', {'item-id': 'i1'});
      await outbox.enqueue('a', {});
      replayer.register('boom', (_) async => throw StateError('bug'));
      replayer.register('a', ok);

      final outcome = await replayer.flush();

      expect(outcome.paused, isFalse);
      expect(outcome.replayed, 1);
      expect(outcome.dropped.single.kind, 'boom');
      expect(await outbox.length, 0);
    },
  );

  test('dispose makes scheduleFlush and start no-ops', () async {
    await replayer.dispose();
    replayer.scheduleFlush(const Duration(seconds: 1));
    replayer.start();
    await outbox.enqueue('a', {});
    await Future<void>.delayed(Duration.zero);
    expect(scheduled, isEmpty);
  });

  test('dispose during flush suppresses backoff scheduling', () async {
    await outbox.enqueue('a', {});
    final gate = Completer<void>();
    replayer.register('a', (_) async {
      await gate.future;
      return Left(const NetworkFailure());
    });

    final running = replayer.flush();
    await replayer.dispose();
    gate.complete();
    final outcome = await running;

    expect(outcome.paused, isTrue);
    expect(scheduled, isEmpty);
  });

  test(
    'notifyServerReachable flushes at once while a retry is pending',
    () async {
      await outbox.enqueue('a', {});
      replayer.register('a', offline);
      await replayer.flush(); // пауза → backoff 5s
      scheduled.clear();

      replayer.notifyServerReachable();

      expect(scheduled, [Duration.zero]);
    },
  );

  test('notifyServerReachable is a no-op without a pending retry', () {
    replayer.notifyServerReachable();
    expect(scheduled, isEmpty);
  });
}
