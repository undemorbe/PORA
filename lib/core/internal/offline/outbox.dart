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

  /// Хвост цепочки мутирующих операций: каждая следующая стартует только
  /// после завершения предыдущей, иначе два быстрых [enqueueCoalesced]
  /// по одному товару переплетаются и оба выживают.
  Future<void> _lock = Future<void>.value();

  /// Выполняет [op] строго после всех ранее поставленных мутаций.
  /// Ошибка [op] уходит вызывающему, но цепочку не ломает.
  Future<T> _serialized<T>(Future<T> Function() op) {
    final result = _lock.then((_) => op());
    _lock = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<OutboxEntry> enqueue(String kind, Map<String, dynamic> args) =>
      _serialized(() => _enqueueUnlocked(kind, args));

  /// Ставит операцию над товаром [itemId], предварительно выкидывая записи,
  /// которые она делает бессмысленными ([OutboxKinds.supersededBy]).
  /// Удаление и постановка выполняются атомарно относительно других мутаций.
  Future<OutboxEntry> enqueueCoalesced(
    String kind,
    Map<String, dynamic> args, {
    required String itemId,
  }) => _serialized(() async {
    final superseded = OutboxKinds.supersededBy(kind);
    if (superseded.isNotEmpty) {
      // Unlocked-хелперы: мы уже внутри замка, повторный вход = deadlock.
      await _removeWhereUnlocked(
        (e) => e.args['item-id'] == itemId && superseded.contains(e.kind),
      );
    }
    return _enqueueUnlocked(kind, args);
  });

  /// Удаляет записи, удовлетворяющие [test]. Возвращает число удалённых.
  Future<int> removeWhere(bool Function(OutboxEntry entry) test) =>
      _serialized(() => _removeWhereUnlocked(test));

  Future<OutboxEntry> _enqueueUnlocked(
    String kind,
    Map<String, dynamic> args,
  ) async {
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

  Future<int> _removeWhereUnlocked(
    bool Function(OutboxEntry entry) test,
  ) async {
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

  /// Есть ли ещё запись [id] в очереди (её могли выкинуть коалесингом).
  Future<bool> contains(String id) async => (await _open()).containsKey(id);

  Future<int> get length async => (await _open()).length;

  /// Перезаписывает существующую запись. Если её уже удалили (коалесинг,
  /// removeWhere) — no-op: иначе put воскресил бы выкинутую операцию.
  Future<void> update(OutboxEntry entry) => _serialized(() async {
    final box = await _open();
    if (!box.containsKey(entry.id)) return;
    await box.put(entry.id, jsonEncode(entry.toJson()));
  });

  Future<void> remove(String id) => _serialized(() async {
    final box = await _open();
    await box.delete(id);
  });

  Future<void> clear() async {
    final box = await _open();
    await box.clear();
  }

  Future<void> dispose() => _changes.close();
}
