import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Данные из кэша вместе с моментом сохранения.
class CacheEntry {
  const CacheEntry({required this.data, required this.savedAt});
  final dynamic data;
  final DateTime savedAt;

  Duration get age => DateTime.now().difference(savedAt);
  bool isStale(Duration maxAge) => age > maxAge;
}

/// JSON-кэш поверх Hive box `pora-cache`.
///
/// Формат записи — конверт `{__v, __ts, __data}` (версия, unix-ms, полезная
/// нагрузка). Старые «сырые» записи без конверта читаются как legacy
/// (age неизвестен → savedAt == epoch). Сериализация/десериализация тяжёлых
/// структур уходит в isolate через compute(), чтобы не лагал main-thread.
///
/// Ключи договорные: `groups`, `list-{lid}`, `notifications`, `user-me`,
/// `statistics-{sub}` и т.п.
class HiveJsonCache {
  const HiveJsonCache._();

  static const _boxName = 'pora-cache';
  static const _vKey = '__v';
  static const _tsKey = '__ts';
  static const _dataKey = '__data';
  static const _version = 1;

  /// Порог, выше которого JSON гоняем через isolate (мелочь дешевле inline).
  static const _isolateThreshold = 8 * 1024;

  static Future<Box<String>> _open() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  /// Сохраняет [value] в конверте с текущим timestamp.
  static Future<void> put(String key, Object value) async {
    final box = await _open();
    final envelope = <String, dynamic>{
      _vKey: _version,
      _tsKey: DateTime.now().millisecondsSinceEpoch,
      _dataKey: value,
    };
    // Кодируем в isolate — большие списки не блокируют UI.
    final encoded = await compute(jsonEncode, envelope);
    await box.put(key, encoded);
  }

  /// Читает полезную нагрузку. `null` если не было / broken.
  static Future<dynamic> read(String key) async {
    final entry = await readEntry(key);
    return entry?.data;
  }

  /// Читает данные + момент сохранения. `null` если не было / broken.
  static Future<CacheEntry?> readEntry(String key) async {
    final box = await _open();
    final raw = box.get(key);
    if (raw == null) return null;
    try {
      final decoded = raw.length > _isolateThreshold
          ? await compute(jsonDecode, raw)
          : jsonDecode(raw);
      return _unwrap(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Читает данные только если они свежее [maxAge]. Иначе `null`
  /// (устаревший кэш не отдаётся, но и не удаляется — им ещё может
  /// воспользоваться offline-фолбэк через [read]).
  static Future<dynamic> readFresh(String key, Duration maxAge) async {
    final entry = await readEntry(key);
    if (entry == null) return null;
    if (entry.isStale(maxAge)) return null;
    return entry.data;
  }

  static CacheEntry _unwrap(dynamic decoded) {
    if (decoded is Map &&
        decoded[_tsKey] is int &&
        decoded.containsKey(_dataKey)) {
      return CacheEntry(
        data: decoded[_dataKey],
        savedAt: DateTime.fromMillisecondsSinceEpoch(decoded[_tsKey] as int),
      );
    }
    // Legacy «сырая» запись — возраст неизвестен.
    return CacheEntry(
      data: decoded,
      savedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
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
