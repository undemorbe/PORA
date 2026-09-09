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

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_outbox_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-outbox');
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    await const Outbox().clear();
  });

  test('successful handlers drain the queue', () async {
    const outbox = Outbox();
    await outbox.enqueue('a', {'n': 1});
    await outbox.enqueue('a', {'n': 2});
    final replayer = OutboxReplayer(outbox: outbox)
      ..register('a', (_) async => Right(const ServerSuccess()));

    await replayer.flush();
    expect(await outbox.length, 0);
  });

  test('connectivity failure pauses flush and keeps entries', () async {
    const outbox = Outbox();
    await outbox.enqueue('a', {});
    final replayer = OutboxReplayer(outbox: outbox)
      ..register('a', (_) async => Left(const NetworkFailure()));

    await replayer.flush();
    expect(await outbox.length, 1); // осталось для следующей попытки
  });

  test('permanent (4xx) failure drops the poisoned entry', () async {
    const outbox = Outbox();
    await outbox.enqueue('a', {});
    final replayer = OutboxReplayer(outbox: outbox)
      ..register('a', (_) async => Left(const ValidationFailure('bad')));

    await replayer.flush();
    expect(await outbox.length, 0);
  });

  test('unknown kind is dropped', () async {
    const outbox = Outbox();
    await outbox.enqueue('unregistered', {});
    final replayer = OutboxReplayer(outbox: outbox);

    await replayer.flush();
    expect(await outbox.length, 0);
  });
}
