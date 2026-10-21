import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_entry.dart';
import 'package:pora/core/internal/offline/outbox_replayer.dart';
import 'package:pora/core/internal/offline/outbox_sync_effects.dart';

void main() {
  // GlobalKey.currentState требует WidgetsBinding.
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_sync_effects_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-cache');
    tmp.deleteSync(recursive: true);
  });

  test('dropped entries invalidate the optimistic item cache', () async {
    await HiveJsonCache.put(CacheKeys.item('i1'), {'id': 'i1'});
    await HiveJsonCache.put(CacheKeys.item('i2'), {'id': 'i2'});
    final outbox = Outbox();
    final replayer = OutboxReplayer(outbox: outbox);
    final effects = OutboxSyncEffects(
      replayer: replayer,
      localeCode: () => 'en',
    );

    // Без смонтированного MaterialApp snackbar — no-op, не падает.
    await effects.handle(
      FlushOutcome(
        dropped: [
          OutboxEntry(
            id: '1',
            kind: 'item.delete',
            args: {'item-id': 'i1'},
            createdAt: 0,
          ),
        ],
      ),
    );

    expect(await HiveJsonCache.read(CacheKeys.item('i1')), isNull);
    expect(await HiveJsonCache.read(CacheKeys.item('i2')), isNotNull);
    await effects.dispose();
    await replayer.dispose();
    await outbox.dispose();
  });
}
