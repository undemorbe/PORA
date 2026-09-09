import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_store.dart';

/// Единое правило offline-first для READ-операций: можно ли отдать кэш
/// вместо живого ответа при ошибке [failure].
///
/// Отдаём кэш только когда проблема в доступности (устройство офлайн, либо
/// ошибка connectivity-типа: таймаут/5xx). При 4xx (403/404/валидация)
/// кэш НЕ отдаём — иначе юзер увидит устаревшие данные вместо честной ошибки
/// (например, список удалён или доступ отозван).
bool canServeCache(Failure failure) {
  final offline = !GetIt.I<ConnectivityStore>().online;
  return offline || failure.isConnectivity;
}
