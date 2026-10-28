import 'package:get_it/get_it.dart';
import 'package:pora/core/features/user/domain/usecase/user/update_device_token.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/network/single_flight.dart';
import 'package:pora/core/internal/notifications/notification_service.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';

bool _boundToAuth = false;

/// Токен, уже доставленный на backend в текущей auth-сессии.
String? _lastSyncedToken;
final _syncFlight = SingleFlight<void>();

/// Однократно подписаться на AuthState.stream — при каждом переходе
/// в `authenticated` (свежий логин или refresh с ролью) шлём токен.
void bindDeviceTokenSyncToAuth() {
  if (_boundToAuth) return;
  final auth = _tryGet<AuthState>();
  if (auth == null) return;
  _boundToAuth = true;
  auth.stream.listen((status) {
    if (status == AuthStatus.authenticated) {
      syncDeviceToken();
    } else {
      // Новый логин (возможно, другим юзером) обязан перерегистрировать токен.
      _lastSyncedToken = null;
    }
  });
}

/// Отправляет FCM/APNS токен на бэкенд через `PUT /user/device`.
/// Оба поля (`device-token`, `device-type`) обязательны — если токен пуст,
/// запрос не отправляется.
///
/// Дёргается из трёх мест:
///   1. AuthState.stream → authenticated (после verifyOtp или refresh).
///   2. AppBootstrap — на всякий случай если pipeline пропустил.
///   3. `FirebaseMessaging.onTokenRefresh` (внутри NotificationService).
///   4. welcome_back / create_profile экраны.
///
/// Тот же токен в рамках auth-сессии повторно не шлётся; параллельные вызовы
/// склеиваются. [force] — ручной resync из advanced settings.
Future<void> syncDeviceToken({bool force = false}) =>
    _syncFlight.run(() => _sync(force: force));

Future<void> _sync({required bool force}) async {
  final auth = _tryGet<AuthState>();
  if (auth == null || !auth.isAuthenticated) {
    _lastSyncedToken = null;
    return;
  }

  final ns = NotificationService.instance;
  final token = ns.fcmToken;
  if (token == null || token.isEmpty) {
    Logger.talker.warning('syncDeviceToken skipped: fcmToken is null');
    return;
  }
  if (!force && token == _lastSyncedToken) return;

  final useCase = _tryGet<UpdateDeviceTokenUseCase>();
  if (useCase == null) return;

  final res = await useCase.call(deviceToken: token, deviceType: ns.deviceType);
  if (res.isLeft) {
    Logger.talker.warning('syncDeviceToken failed: ${res.left.message}');
  } else {
    _lastSyncedToken = token;
  }
}

T? _tryGet<T extends Object>() {
  try {
    return GetIt.I.isRegistered<T>() ? GetIt.I<T>() : null;
  } catch (_) {
    return null;
  }
}
