import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/offline/outbox_kinds.dart';

void main() {
  late Directory tmp;
  late Outbox outbox;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_outbox_coalesce_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-outbox');
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    outbox = Outbox();
    await outbox.clear();
  });

  tearDown(() => outbox.dispose());

  Future<List<String>> kinds() async =>
      (await outbox.all()).map((e) => e.kind).toList();

  test('markBought on the same item keeps only the last value', () async {
    await outbox.enqueueCoalesced(OutboxKinds.itemMarkBought, {
      'item-id': 'i1',
      'checked': true,
    }, itemId: 'i1');
    await outbox.enqueueCoalesced(OutboxKinds.itemMarkBought, {
      'item-id': 'i1',
      'checked': false,
    }, itemId: 'i1');

    final all = await outbox.all();
    expect(all, hasLength(1));
    expect(all.single.args['checked'], isFalse);
  });

  test('different items are not coalesced', () async {
    await outbox.enqueueCoalesced(OutboxKinds.itemMarkBought, {
      'item-id': 'i1',
      'checked': true,
    }, itemId: 'i1');
    await outbox.enqueueCoalesced(OutboxKinds.itemMarkBought, {
      'item-id': 'i2',
      'checked': true,
    }, itemId: 'i2');

    expect(await outbox.length, 2);
  });

  test('delete supersedes every earlier op on that item only', () async {
    await outbox.enqueueCoalesced(OutboxKinds.itemUpdate, {
      'item-id': 'i1',
      'body': {'name': 'x'},
    }, itemId: 'i1');
    await outbox.enqueueCoalesced(OutboxKinds.itemNotify, {
      'item-id': 'i1',
      'message': 'm',
    }, itemId: 'i1');
    await outbox.enqueueCoalesced(OutboxKinds.itemMarkBought, {
      'item-id': 'i2',
      'checked': true,
    }, itemId: 'i2');
    await outbox.enqueueCoalesced(OutboxKinds.itemDelete, {
      'item-id': 'i1',
    }, itemId: 'i1');

    expect(await kinds(), [OutboxKinds.itemMarkBought, OutboxKinds.itemDelete]);
  });

  test('notify is never coalesced', () async {
    for (final m in ['a', 'b']) {
      await outbox.enqueueCoalesced(OutboxKinds.itemNotify, {
        'item-id': 'i1',
        'message': m,
      }, itemId: 'i1');
    }
    expect(await outbox.length, 2);
  });

  test('removeWhere returns number of removed entries', () async {
    await outbox.enqueue('a', {});
    await outbox.enqueue('b', {});
    expect(await outbox.removeWhere((e) => e.kind == 'a'), 1);
    expect(await kinds(), ['b']);
  });

  test('changes emits on enqueue', () async {
    final emitted = outbox.changes.first;
    await outbox.enqueue('a', {});
    await expectLater(emitted, completes);
  });
}
