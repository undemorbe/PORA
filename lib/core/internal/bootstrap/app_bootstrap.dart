import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart' show Locale;
import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pora/core/internal/di/injection_container.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/notifications/deep_link_handler.dart';
import 'package:pora/core/internal/notifications/device_token_sync.dart';
import 'package:pora/core/internal/offline/outbox_replayer.dart';
import 'package:pora/core/internal/platform/app_shortcuts_service.dart';
import 'package:pora/core/internal/platform/share_intent_service.dart';

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

  void start(InjectionContainer container) {
    _future ??= _run(container);
  }

  Future<void> _run(InjectionContainer container) async {
    final sw = Stopwatch()..start();
    try {
      unawaited(container.getIt<ConnectivityStore>().init());

      await Future.wait<void>([
        _initLocalization(container),
        _refreshAndAuth(container),
      ]);

      _bindOutboxToConnectivity(container);
      unawaited(_initPlatformIntegrations(container));

      Logger.talker.info('AppBootstrap ready in ${sw.elapsedMilliseconds}ms');

      unawaited(_startBackgroundServices());
    } catch (e, s) {
      Logger.talker.error('AppBootstrap failed', e, s);
    }
  }

  /// Проигрываем offline-очередь при старте (если онлайн) и на каждом
  /// восстановлении связи.
  void _bindOutboxToConnectivity(InjectionContainer container) {
    final connectivity = container.getIt<ConnectivityStore>();
    final replayer = container.getIt<OutboxReplayer>();
    if (connectivity.online) unawaited(replayer.flush());
    // reaction живёт весь lifecycle приложения (singleton не диспоузится).
    reaction<bool>((_) => connectivity.online, (online) {
      if (online) unawaited(replayer.flush());
    });
  }

  /// Платформенные интеграции: App Shortcuts (иконка long-press) + Share-to-app
  /// (импорт рецептов по шарингу). Локализованные подписи берём из активной
  /// локали.
  Future<void> _initPlatformIntegrations(InjectionContainer container) async {
    try {
      final locale = Locale(container.getIt<LocalizationStore>().currentLocale);
      final l = lookupAppLocalizations(locale);
      await AppShortcutsService.instance.init(
        listsLabel: l.navList,
        poraLabel: l.navPora,
        addLabel: l.shortcutAddItem,
      );
      await ShareIntentService.instance.init();
    } catch (e, s) {
      Logger.talker.warning('Platform integrations init failed', e, s);
    }
  }

  Future<void> _startBackgroundServices() async {
    try {
      await _initFirebaseAndPush();
      await _openAppWebsocket();
      bindDeviceTokenSyncToAuth();
      unawaited(syncDeviceToken());
    } catch (e, s) {
      Logger.talker.warning('Background services failed to start', e, s);
    }
  }

  Future<void> _initFirebaseAndPush() async {
    // iOS push требует APNs-ключа в Firebase + Push Notifications capability и
    // aps-environment entitlement в Runner (настраивается в Xcode). Код-путь
    // общий для обеих платформ; сбой getToken на iOS без APNs не критичен —
    // обёрнут в try/catch вызывающего _startBackgroundServices.
    await Firebase.initializeApp();
    // Crashlytics: включаем сбор (в debug — нет, чтобы не шуметь) + аналитика.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    unawaited(AnalyticsService.instance.init());
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

  // Подписка живёт весь lifecycle приложения (singleton не диспоузится).
  // ignore: cancel_subscriptions
  StreamSubscription<AuthStatus>? _wsAuthSub;

  Future<void> _openAppWebsocket() async {
    final rawUrl = dotenv.maybeGet('WS_URL');
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      Logger.talker.warning('WS_URL not configured — websocket disabled');
      return;
    }
    final wsUrl = Uri.tryParse(rawUrl.trim());
    if (wsUrl == null) {
      Logger.talker.warning('WS_URL is not a valid URI — websocket disabled');
      return;
    }

    final auth = GetIt.I<AuthState>();
    if (auth.isAuthenticated) {
      AppWebsocket.instance.connect(wsUrl);
    }

    // Держим одну подписку на весь lifecycle приложения (singleton никогда
    // не диспоузится — отмена не нужна).
    // ignore: cancel_subscriptions
    _wsAuthSub ??= auth.stream.listen((event) {
      if (event == AuthStatus.authenticated) {
        AppWebsocket.instance.connect(wsUrl);
      } else {
        AppWebsocket.instance.disconnect();
      }
    });
  }
}
