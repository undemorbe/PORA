import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';

/// Точечно правит товар во всех закэшированных снапшотах списков
/// (`list-content-v1-*`), чтобы offline-изменение пережило переоткрытие
/// списка. Формат снапшота — `ListModel.toJson()`:
/// `{id, name, sections: [{name, items: [ProductModel.toJson()]}]}`.
class ListCachePatcher {
  const ListCachePatcher();

  /// Ищет товар [itemId] в снапшотах списков — офлайн-фолбэк для карточки
  /// товара, которую не открывали онлайн. В JSON товара внутри списка нет
  /// `section`, поэтому подставляем имя секции снапшота. `null` — не найден.
  Future<Map<String, dynamic>?> findItem(String itemId) async {
    final keys = await HiveJsonCache.keysWithPrefix(
      CacheKeys.listContentPrefix,
    );
    for (final key in keys) {
      final raw = await HiveJsonCache.read(key);
      if (raw is! Map || raw['sections'] is! List) continue;
      for (final s in raw['sections'] as List) {
        if (s is! Map || s['items'] is! List) continue;
        for (final it in s['items'] as List) {
          if (it is Map && it['id'] == itemId) {
            return Map<String, dynamic>.from(it)
              ..putIfAbsent('section', () => s['name']);
          }
        }
      }
    }
    return null;
  }

  /// Мержит [patch] в товар [itemId] во всех списках, где он есть.
  Future<void> patchItem(String itemId, Map<String, dynamic> patch) =>
      _rewrite((items) {
        var changed = false;
        for (var i = 0; i < items.length; i++) {
          final it = items[i];
          if (it is Map && it['id'] == itemId) {
            items[i] = Map<String, dynamic>.from(it)..addAll(patch);
            changed = true;
          }
        }
        return changed;
      });

  /// Убирает товар [itemId] из всех списков; опустевшие из-за этого секции
  /// удаляются (как в `ListStore.deleteItem`).
  Future<void> removeItem(String itemId) => _rewrite((items) {
    final before = items.length;
    items.removeWhere((it) => it is Map && it['id'] == itemId);
    return items.length != before;
  }, dropEmptySections: true);

  /// Пишет целый снапшот списка [key] (write-through из `ListStore`) через
  /// ту же очередь, что и патчи: свежий снапшот не затрёт идущий патч, а
  /// патч не потеряется, наложившись на устаревшие данные.
  Future<void> writeSnapshot(String key, Map<String, dynamic> json) =>
      _enqueue(() => HiveJsonCache.put(key, json));

  /// Все правки снапшотов идут строго по очереди: read→edit→write с await
  /// между шагами, параллельные вызовы иначе затирают друг друга.
  static Future<void> _tail = Future.value();

  /// Тело не должно снова заходить в эту очередь ([_enqueue]) — иначе дедлок.
  Future<void> _rewrite(
    bool Function(List<dynamic> items) edit, {
    bool dropEmptySections = false,
  }) => _enqueue(() => _doRewrite(edit, dropEmptySections: dropEmptySections));

  Future<void> _enqueue(Future<void> Function() body) {
    final next = _tail.then((_) => body());
    // Ошибка одной правки не должна рвать очередь для следующих.
    _tail = next.catchError((Object _) {});
    return next;
  }

  /// [edit] мутирует копию `items` секции и возвращает, изменила ли что-то.
  Future<void> _doRewrite(
    bool Function(List<dynamic> items) edit, {
    required bool dropEmptySections,
  }) async {
    final keys = await HiveJsonCache.keysWithPrefix(
      CacheKeys.listContentPrefix,
    );
    for (final key in keys) {
      final raw = await HiveJsonCache.read(key);
      if (raw is! Map) continue;
      final sections = raw['sections'];
      if (sections is! List) continue;

      var changed = false;
      final newSections = <dynamic>[];
      for (final s in sections) {
        if (s is! Map || s['items'] is! List) {
          newSections.add(s);
          continue;
        }
        final items = List<dynamic>.from(s['items'] as List);
        final edited = edit(items);
        if (edited) changed = true;
        if (dropEmptySections && edited && items.isEmpty) continue;
        newSections.add(Map<String, dynamic>.from(s)..['items'] = items);
      }
      if (!changed) continue;
      await HiveJsonCache.put(
        key,
        Map<String, dynamic>.from(raw)..['sections'] = newSections,
      );
    }
  }
}
