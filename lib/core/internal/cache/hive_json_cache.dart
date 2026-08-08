import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Простой JSON-кэш поверх Hive box `pora-cache`.
/// Стратегия: `readThrough(key, fetch)` — пробует сеть, при успехе кладёт
/// JSON в Hive и возвращает; при ошибке — читает последнее сохранённое.
///
/// Ключи договорные: `groups`, `list-{lid}`, `notifications`, `user-me`,
/// `statistics-{sub}` и т.п.
class HiveJsonCache {
  const HiveJsonCache._();

  static const _boxName = 'pora-cache';

  static Future<Box<String>> _open() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  /// Сохраняет [value] (сериализуется как JSON).
  static Future<void> put(String key, Object value) async {
    final box = await _open();
    await box.put(key, jsonEncode(value));
  }

  /// Читает JSON. `null` если не было или broken.
  static Future<dynamic> read(String key) async {
    final box = await _open();
    final raw = box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Удаляет ключ.
  static Future<void> invalidate(String key) async {
    final box = await _open();
    await box.delete(key);
  }

  /// Полная очистка (например при logout).
  static Future<void> clear() async {
    final box = await _open();
    await box.clear();
  }
}
