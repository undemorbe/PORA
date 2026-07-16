import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pora/app/features/auth_and_validation/data/datasource/local/secure_tokens.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/refresh_token.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/theme/store/theme_store.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/notifications/deep_link_handler.dart';
import 'package:pora/app/internal/notifications/device_token_sync.dart';
import 'package:pora/app/internal/notifications/notification_service.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';

/// Тяжёлая инициализация, идущая параллельно со splash-анимацией.
///
/// main.dart запускает [start] и сразу вызывает `runApp` — экран не
/// блокируется. SplashPage ждёт [ready] перед навигацией.
class AppBootstrap {
  AppBootstrap._();
  static final AppBootstrap instance = AppBootstrap._();

  Future<void>? _future;

  /// Готов ли runtime к навигации. Идемпотентно — можно `await` из
  /// нескольких мест.
  Future<void> get ready {
    final f = _future;
    if (f == null) {
      throw StateError('AppBootstrap.start() not called yet');
    }
    return f;
  }

  /// Запуск. Не await'ится в main — крутится параллельно splash.
  void start(InjectionContainer container) {
    _future ??= _run(container);
  }

  Future<void> _run(InjectionContainer container) async {
    final sw = Stopwatch()..start();
    try {
      // Hive нужен и notifications, и refresh (secure_store), и локализации.
      final localDB = container.getIt<ILocalDB<dynamic>>();
      await localDB.init();

      // Три параллельных ветки — независимы, ускоряют cold start.
      await Future.wait<void>([
        _initFirebaseAndPush(),
        _initLocalization(container),
        _refreshAndAuth(container),
      ]);

      // Депендс от secure store (запись в кэш) — после refresh.
      final tokensStore = container.getIt<TokensSecureStore>();
      tokensStore.updateCache(await tokensStore.getAccessToken());

      // Auth готов + FCM token готов → регистрируем устройство.
      // No-op если не authed либо fcmToken пустой.
      bindDeviceTokenSyncToAuth();
      unawaited(syncDeviceToken());

      Logger.talker.info('AppBootstrap ready in ${sw.elapsedMilliseconds}ms');
    } catch (e, s) {
      Logger.talker.error('AppBootstrap failed', e, s);
      // Не rethrow — splash всё равно должен перейти дальше;
      // guards/screens сами обработают missing state.
    }
  }

  Future<void> _initFirebaseAndPush() async {
    await Firebase.initializeApp();
    await NotificationService.instance.init();
    DeepLinkHandler.instance.bindToAuth();
  }

  Future<void> _initLocalization(InjectionContainer container) async {
    await container.getIt<LocalizationStore>().initialise();
    await container.getIt<ThemeStore>().initialiseTheme();
  }

  Future<void> _refreshAndAuth(InjectionContainer container) async {
    final refreshed = await container.getIt<RefreshTokenUseCase>().call();
    final auth = container.getIt<AuthState>();
    if (refreshed != null && refreshed.isLeft) {
      final tokensStore = container.getIt<TokensSecureStore>();
      final accessToken = await tokensStore.getAccessToken();
      final refreshToken = await tokensStore.getRefreshToken();
      if (accessToken != null && refreshToken != null ||
          dotenv.getBool('DEBUG')) {
        auth.setAuthenticated();
      } else {
        auth.setUnauthenticated();
      }
    } else {
      auth.setAuthenticated();
    }
  }
}
