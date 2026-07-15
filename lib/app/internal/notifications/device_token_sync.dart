import 'package:get_it/get_it.dart';
import 'package:pora/app/features/user/domain/usecase/user/update_device_token.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/notifications/notification_service.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';

bool _boundToAuth = false;

/// Однократно подписаться на AuthState.stream — при каждом переходе
/// в `authenticated` (свежий логин или refresh с ролью) шлём токен.
void bindDeviceTokenSyncToAuth() {
  if (_boundToAuth) return;
  final auth = _tryGet<AuthState>();
  if (auth == null) return;
  _boundToAuth = true;
  auth.stream.listen((status) {
    if (status == AuthStatus.authenticated) syncDeviceToken();
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
Future<void> syncDeviceToken() async {
  final auth = _tryGet<AuthState>();
  if (auth == null || !auth.isAuthenticated) return;

  final ns = NotificationService.instance;
  final token = ns.fcmToken;
  if (token == null || token.isEmpty) {
    Logger.talker.warning('syncDeviceToken skipped: fcmToken is null');
    return;
  }

  final useCase = _tryGet<UpdateDeviceTokenUseCase>();
  if (useCase == null) return;

  final res = await useCase.call(
    deviceToken: token,
    deviceType: ns.deviceType,
  );
  if (res.isLeft) {
    Logger.talker.warning(
      'syncDeviceToken failed: ${res.left.message}',
    );
  }
}

T? _tryGet<T extends Object>() {
  try {
    return GetIt.I.isRegistered<T>() ? GetIt.I<T>() : null;
  } catch (_) {
    return null;
  }
}
