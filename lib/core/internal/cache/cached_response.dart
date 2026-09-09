import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';

/// Результат `cachedOrLive` — данные + флаг «из кэша».
class CachedResult<T> {
  const CachedResult({required this.data, required this.fromCache});
  final T data;
  final bool fromCache;
}

/// Отдавать ли кэш при данной ошибке. По умолчанию — только когда проблема
/// в доступности сервиса (offline/timeout/5xx), но НЕ при 4xx/валидации:
/// иначе юзер увидит старые данные вместо честной ошибки (например, 403).
bool _defaultShouldServeCache(Failure f) =>
    f.isConnectivity ||
    (f is ApiFailure && (f.statusCode == null || f.statusCode! >= 500));

/// Read-through helper.
/// Ход:
///   1. Пробует `fetch()` (сеть).
///   2. На успех — сохраняет JSON в Hive под [key], возвращает `data`.
///   3. На ошибку — маппит её в [Failure]; если ошибка connectivity-типа
///      (см. [shouldServeCache]) и кэш есть — возвращает `data` c
///      `fromCache=true`; битый кэш инвалидируется. Иначе — пробрасывает
///      исходную ошибку (её домэппит вызывающий слой).
///
/// [toJson] должен превращать T в JSON-совместимый Map/List.
/// [fromJson] воссоздаёт T из прочитанного JSON.
Future<CachedResult<T>> cachedOrLive<T>({
  required String key,
  required Future<T> Function() fetch,
  required Object Function(T) toJson,
  required T Function(dynamic) fromJson,
  bool Function(Failure failure)? shouldServeCache,
}) async {
  try {
    final live = await fetch();
    await HiveJsonCache.put(key, toJson(live));
    return CachedResult(data: live, fromCache: false);
  } catch (e, s) {
    final failure = FailureMapper.map(e, s);
    final eligible = (shouldServeCache ?? _defaultShouldServeCache)(failure);
    if (eligible) {
      final cached = await HiveJsonCache.read(key);
      if (cached != null) {
        try {
          return CachedResult(data: fromJson(cached), fromCache: true);
        } catch (_) {
          // Битый кэш — удаляем, чтобы не залипал, и пробрасываем ошибку.
          await HiveJsonCache.invalidate(key);
        }
      }
    }
    rethrow;
  }
}
