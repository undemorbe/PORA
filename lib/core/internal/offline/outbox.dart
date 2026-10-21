import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/offline/outbox_entry.dart';
import 'package:pora/core/internal/offline/outbox_kinds.dart';

/// Персистентная offline-очередь write-операций поверх Hive box `pora-outbox`.
/// Операции, сделанные без сети, складываются сюда и проигрываются
/// OutboxReplayer'ом при восстановлении связи.
class Outbox {
  Outbox();

  static const _boxName = 'pora-outbox';
  static int _seq = 0;

  final _changes = StreamController<void>.broadcast();

  /// Эмитит после каждой постановки в очередь — по нему OutboxReplayer
  /// планирует flush.
  Stream<void> get changes => _changes.stream;

  Future<Box<String>> _open() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    return Hive.openBox<String>(_boxName);
  }

  /// Генерирует монотонный id (timestamp + счётчик в рамках сессии).
  static String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  Future<OutboxEntry> enqueue(String kind, Map<String, dynamic> args) async {
    final box = await _open();
    final entry = OutboxEntry(
      id: newId(),
      kind: kind,
      args: args,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await box.put(entry.id, jsonEncode(entry.toJson()));
    if (!_changes.isClosed) _changes.add(null);
    return entry;
  }

  /// Ставит операцию над товаром [itemId], предварительно выкидывая записи,
  /// которые она делает бессмысленными ([OutboxKinds.supersededBy]).
  Future<OutboxEntry> enqueueCoalesced(
    String kind,
    Map<String, dynamic> args, {
    required String itemId,
  }) async {
    final superseded = OutboxKinds.supersededBy(kind);
    if (superseded.isNotEmpty) {
      await removeWhere(
        (e) => e.args['item-id'] == itemId && superseded.contains(e.kind),
      );
    }
    return enqueue(kind, args);
  }

  /// Удаляет записи, удовлетворяющие [test]. Возвращает число удалённых.
  Future<int> removeWhere(bool Function(OutboxEntry entry) test) async {
    final box = await _open();
    final doomed = (await all()).where(test).map((e) => e.id).toList();
    await box.deleteAll(doomed);
    return doomed.length;
  }

  /// Все записи в порядке создания.
  Future<List<OutboxEntry>> all() async {
    final box = await _open();
    final entries = <OutboxEntry>[];
    for (final raw in box.values) {
      try {
        entries.add(
          OutboxEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // Битая запись — пропускаем (будет вычищена при clear).
      }
    }
    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entries;
  }

  Future<int> get length async => (await _open()).length;

  Future<void> update(OutboxEntry entry) async {
    final box = await _open();
    await box.put(entry.id, jsonEncode(entry.toJson()));
  }

  Future<void> remove(String id) async {
    final box = await _open();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _open();
    await box.clear();
  }

  Future<void> dispose() => _changes.close();
}
