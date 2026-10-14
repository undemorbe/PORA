import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

import '../helpers/fake_local_db.dart';

void main() {
  late DateTime clock;
  UsageTracker tracker() => UsageTracker(clock: () => clock);

  setUp(() => clock = DateTime(2026, 10, 6, 10));

  test('events before attach are buffered and replayed', () async {
    final t = tracker()
      ..itemAdded(section: 'Овощи')
      ..itemBought(name: 'Томаты');
    expect(t.days, isEmpty);
    await t.attach(FakeLocalDB());
    final today = t.days['2026-10-06']!;
    expect(today.added, 1);
    expect(today.bought, 1);
    expect(today.addedSections, {'Овощи': 1});
    expect(today.boughtNames, {'Томаты': 1});
    expect(today.hourAt(10), 2);
  });

  test('flush persists and a new tracker restores history', () async {
    final db = FakeLocalDB();
    final t = tracker();
    await t.attach(db);
    t
      ..listOpened()
      ..recipeImported();
    await t.flush();

    final restored = tracker();
    await restored.attach(db);
    final today = restored.days['2026-10-06']!;
    expect(today.listsOpened, 1);
    expect(today.recipes, 1);
  });

  test('records older than retention are dropped on load', () async {
    final db = FakeLocalDB();
    final old = tracker();
    clock = DateTime(2026, 1, 1, 12);
    await old.attach(db);
    old.itemAdded();
    await old.flush();

    clock = DateTime(2026, 10, 6, 12);
    final t = tracker();
    await t.attach(db);
    expect(t.days, isEmpty);
  });

  test('session: repeated start is ignored, end accumulates seconds', () async {
    final t = tracker();
    await t.attach(FakeLocalDB());
    t.sessionStarted();
    clock = clock.add(const Duration(seconds: 30));
    t.sessionStarted(); // inactive → resumed — та же сессия
    clock = clock.add(const Duration(seconds: 90));
    t.sessionEnded();
    t.sessionEnded(); // идемпотентно
    final today = t.days['2026-10-06']!;
    expect(today.opens, 1);
    expect(today.seconds, 120);
  });

  test('implausible session length is discarded', () async {
    final t = tracker();
    await t.attach(FakeLocalDB());
    t.sessionStarted();
    clock = clock.add(const Duration(hours: 9));
    t.sessionEnded();
    expect(t.days['2026-10-06']!.seconds, 0);
  });

  test('writes are debounced', () {
    fakeAsync((async) {
      final db = FakeLocalDB();
      Object? stored;
      void read() => db
          .get(key: UsageTracker.storageKey, boxName: LocalDBNames.settings)
          .then((v) => stored = v);

      final t = tracker();
      t.attach(db);
      async.elapse(const Duration(seconds: 2)); // attach-persist отработал
      t.itemDeleted();
      async.elapse(const Duration(milliseconds: 500));
      t.itemDeleted();
      async.elapse(const Duration(milliseconds: 500));
      read();
      async.flushMicrotasks();
      expect(stored, isNot(contains('"deleted"'))); // таймер ещё не сработал

      async.elapse(const Duration(seconds: 2));
      read();
      async.flushMicrotasks();
      expect(stored, contains('"deleted":2'));
    });
  });

  test('clear wipes memory and storage', () async {
    final db = FakeLocalDB();
    final t = tracker();
    await t.attach(db);
    t.aiMessageSent();
    await t.flush();
    await t.clear();
    expect(t.days, isEmpty);
    expect(
      await db.get(
        key: UsageTracker.storageKey,
        boxName: LocalDBNames.settings,
      ),
      isNull,
    );
  });
}
