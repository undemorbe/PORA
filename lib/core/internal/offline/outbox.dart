import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/offline/outbox_entry.dart';

/// Персистентная offline-очередь write-операций поверх Hive box `pora-outbox`.
/// Операции, сделанные без сети, складываются сюда и проигрываются
/// OutboxReplayer'ом при восстановлении связи.
class Outbox {
  const Outbox();

  static const _boxName = 'pora-outbox';
  static int _seq = 0;

  Future<Box<String>> _open() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    return Hive.openBox<String>(_boxName);
  }

  /// Генерирует монотонный id (timestamp + счётчик в рамках сессии).
  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  Future<OutboxEntry> enqueue(String kind, Map<String, dynamic> args) async {
    final box = await _open();
    final entry = OutboxEntry(
      id: newId(),
      kind: kind,
      args: args,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await box.put(entry.id, jsonEncode(entry.toJson()));
    return entry;
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
}
