import 'dart:async';
import 'dart:io';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pora/core/internal/di/injection_container.dart';
import 'package:pora/core/internal/notifications/deep_link_handler.dart';
import 'package:pora/core/internal/notifications/device_token_sync.dart';

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

      // Connectivity — быстрый init, синхронно.
      unawaited(container.getIt<ConnectivityStore>().init());

      // Три параллельных ветки — независимы, ускоряют cold start.
      await Future.wait<void>([
        _initLocalization(container),
        _refreshAndAuth(container),
      ]);
      if (!Platform.isIOS) {
        //!!!!! Add ios compatibility
        _initFirebaseAndPush();
      }

      // Депендс от secure store (запись в кэш) — после refresh.
      final tokensStore = container.getIt<TokensSecureStore>();
      tokensStore.updateCache(await tokensStore.getAccessToken());

      // Auth готов + FCM token готов → регистрируем устройство.
      // No-op если не authed либо fcmToken пустой.
      await _openAppWebsocket();
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
      if (accessToken != null && refreshToken != null) {
        auth.setAuthenticated();
      } else {
        auth.setUnauthenticated();
      }
    } else {
      final tokensStore = container.getIt<TokensSecureStore>();
      final accessToken = await tokensStore.getAccessToken();
      final refreshToken = await tokensStore.getRefreshToken();
      if (accessToken != null && refreshToken != null) {
        auth.setAuthenticated();
      } else {
        auth.setUnauthenticated();
      }
    }
  }

  Future<void> _openAppWebsocket() async {
    Logger.talker.debug('Starting openning ws');
    final wsUrl = Uri.parse(dotenv.get('WS_URL'));
    final auth = GetIt.I<AuthState>();
    if (auth.isAuthenticated) {
      Logger.talker.debug('Auth = true, creating ws');
      AppWebsocket.instance.connect(wsUrl);
    }

    auth.stream.listen((event) {
      if (event == AuthStatus.authenticated) {
        AppWebsocket.instance.connect(wsUrl);
      } else {
        AppWebsocket.instance.disconnect();
      }
    });
  }
}
