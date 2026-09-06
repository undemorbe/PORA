import 'dart:async';
import 'dart:io';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pora/core/internal/di/injection_container.dart';
import 'package:pora/core/internal/notifications/deep_link_handler.dart';
import 'package:pora/core/internal/notifications/device_token_sync.dart';

class AppBootstrap {
  AppBootstrap._();
  static final AppBootstrap instance = AppBootstrap._();

  Future<void>? _future;

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

      // Локальная инициализация не должна зависеть от доступности API.
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
    final auth = container.getIt<AuthState>();
    final tokensStore = container.getIt<TokensSecureStore>();
    final accessToken = await tokensStore.getAccessToken();
    final refreshToken = await tokensStore.getRefreshToken();

    tokensStore.updateCache(accessToken);
    if (accessToken != null && refreshToken != null) {
      auth.setAuthenticated();
    } else {
      auth.setUnauthenticated();
    }

    // Refresh is best-effort. A slow or unavailable API must not keep the
    // splash screen open; AuthInterceptor will use the updated cache once it
    // completes.
    if (refreshToken != null && refreshToken.isNotEmpty) {
      unawaited(_refreshInBackground(container));
    }
  }

  Future<void> _refreshInBackground(InjectionContainer container) async {
    try {
      final refreshed = await container.getIt<RefreshTokenUseCase>().call();
      if (refreshed?.isRight ?? false) {
        container.getIt<TokensSecureStore>().updateCache(
          refreshed!.right.accessToken,
        );
      }
    } catch (e, s) {
      Logger.talker.warning('Background token refresh failed', e, s);
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
