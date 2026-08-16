import 'package:pora/core/internal/cache/hive_json_cache.dart';

/// Результат `cachedOrLive` — данные + флаг «из кэша».
class CachedResult<T> {
  const CachedResult({required this.data, required this.fromCache});
  final T data;
  final bool fromCache;
}

/// Read-through helper.
/// Ход:
///   1. Пробует `fetch()` (сеть).
///   2. На успех — сохраняет JSON в Hive под [key], возвращает `data`.
///   3. На ошибку — читает кэш; если есть — возвращает `data` c
///      `fromCache=true`; иначе — пробрасывает исходную ошибку.
///
/// [toJson] должен превращать T в JSON-совместимый Map/List.
/// [fromJson] воссоздаёт T из прочитанного JSON.
Future<CachedResult<T>> cachedOrLive<T>({
  required String key,
  required Future<T> Function() fetch,
  required Object Function(T) toJson,
  required T Function(dynamic) fromJson,
}) async {
  try {
    final live = await fetch();
    await HiveJsonCache.put(key, toJson(live));
    return CachedResult(data: live, fromCache: false);
  } catch (e) {
    final cached = await HiveJsonCache.read(key);
    if (cached != null) {
      try {
        return CachedResult(data: fromJson(cached), fromCache: true);
      } catch (_) {
        rethrow;
      }
    }
    rethrow;
  }
}
