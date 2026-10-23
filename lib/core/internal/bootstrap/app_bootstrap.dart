import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, visibleForTesting;
import 'package:flutter/widgets.dart' show AppLifecycleListener, Locale;
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/backend/api_analytics_sender.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_session_listener.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pora/core/internal/di/injection_container.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/notifications/deep_link_handler.dart';
import 'package:pora/core/internal/notifications/device_token_sync.dart';
import 'package:pora/core/internal/offline/outbox_replayer.dart';
import 'package:pora/core/internal/offline/outbox_sync_effects.dart';
import 'package:pora/core/internal/platform/app_shortcuts_service.dart';
import 'package:pora/core/internal/platform/share_intent_service.dart';

/// Backend-сессия на логине: только повторный вход в рамках того же запуска
/// (`unauthenticated → authenticated`). Холодный старт (`unknown →
/// authenticated`) уже отметил `UsageSessionListener`.
@visibleForTesting
bool shouldStartSessionOnAuth(AuthStatus prev, AuthStatus next) =>
    prev == AuthStatus.unauthenticated && next == AuthStatus.authenticated;

class AppBootstrap {
  AppBootstrap._();
  static final AppBootstrap instance = AppBootstrap._();

  /// Держит подписку на resume для flush offline-очереди.
  AppLifecycleListener? _outboxLifecycle;

  /// Подписки backend-аналитики: логин → flush, появление сети → flush.
  StreamSubscription<AuthStatus>? _analyticsAuthSub;
  ReactionDisposer? _analyticsOnlineReaction;

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
      // Локальная статистика пользования: сессии + история для Insights.
      UsageSessionListener.start();
      unawaited(
        UsageTracker.instance.attach(container.getIt<ILocalDB<dynamic>>()),
      );
      // Клиентские события → бэкенд (админ-панель аналитики).
      unawaited(_attachAnalyticsSink(container));

      // finally: ошибка локализации/авторизации не должна оставить outbox
      // непривязанным (локаль читается лениво). Сама ошибка летит дальше в
      // общий catch — платформенные интеграции и фон, как и раньше, пропускаем.
      try {
        await Future.wait<void>([
          _initLocalization(container),
          _refreshAndAuth(container),
        ]);
      } finally {
        _bindOutboxToConnectivity(container);
      }
      unawaited(_initPlatformIntegrations(container));

      Logger.talker.info('AppBootstrap ready in ${sw.elapsedMilliseconds}ms');

      unawaited(_startBackgroundServices());
    } catch (e, s) {
      Logger.talker.error('AppBootstrap failed', e, s);
    }
  }

  /// Проигрываем offline-очередь: при старте (если онлайн), на каждом
  /// восстановлении связи, при возврате из фона и вскоре после постановки
  /// новой записи (`replayer.start()`). Ошибки связи — backoff внутри
  /// replayer'а.
  void _bindOutboxToConnectivity(InjectionContainer container) {
    final connectivity = container.getIt<ConnectivityStore>();
    final replayer = container.getIt<OutboxReplayer>()..start();
    OutboxSyncEffects(
      replayer: replayer,
      localeCode: () => container.getIt<LocalizationStore>().currentLocale,
    ).start();
    if (connectivity.online) unawaited(replayer.flush());
    // reaction и listener живут весь lifecycle приложения (singleton'ы не
    // диспоузятся).
    reaction<bool>((_) => connectivity.online, (online) {
      if (online) unawaited(replayer.flush());
    });
    // Возврат из фона: сеть могла появиться, пока процесс спал.
    _outboxLifecycle ??= AppLifecycleListener(
      onResume: () {
        if (connectivity.online) unawaited(replayer.flush());
      },
    );
  }

  /// Очередь клиентских событий: шлём только авторизованным и онлайн;
  /// дополнительно сбрасываем её при логине и при появлении сети. Эти два
  /// триггера — свежие условия, поэтому flush с `force` (минуя backoff);
  /// периодический и lifecycle-flush идут без него.
  Future<void> _attachAnalyticsSink(InjectionContainer container) async {
    try {
      final auth = container.getIt<AuthState>();
      final connectivity = container.getIt<ConnectivityStore>();
      final api = container.getIt<ApiClient>();
      final sink = BackendEventSink.instance;
      // Без версии аналитика всё равно нужна — шлём с 'unknown'.
      String appVersion;
      try {
        appVersion = (await PackageInfo.fromPlatform()).version;
      } catch (e, s) {
        Logger.talker.warning('PackageInfo unavailable for analytics', e, s);
        appVersion = 'unknown';
      }

      await sink.attach(
        db: container.getIt<ILocalDB<dynamic>>(),
        sender: apiAnalyticsSender(
          (body) => api.sendAnalyticsEvents(body: body),
        ),
        canSend: () => auth.isAuthenticated && connectivity.online,
        platform: _analyticsPlatform(),
        appVersion: appVersion,
      );

      // Подписки живут весь lifecycle приложения (singleton не диспоузится);
      // `??=` — повторный attach не подписывается дважды.
      var lastStatus = auth.status;
      _analyticsAuthSub ??= auth.stream.listen((status) {
        final prev = lastStatus;
        lastStatus = status;
        if (status != AuthStatus.authenticated) return;
        if (shouldStartSessionOnAuth(prev, status)) {
          unawaited(AnalyticsService.instance.logSessionStart());
        }
        unawaited(sink.flush(force: true));
      });
      _analyticsOnlineReaction ??= reaction<bool>((_) => connectivity.online, (
        online,
      ) {
        if (online) unawaited(sink.flush(force: true));
      });
      // Хвост прошлого запуска: авторизация могла выставиться до подписки
      // (attach ждёт PackageInfo) — не ждём периодического таймера.
      unawaited(sink.flush());
    } catch (e, s) {
      Logger.talker.warning('Analytics sink attach failed', e, s);
    }
  }

  /// Снимает подписки backend-аналитики. В приложении не вызывается
  /// (singleton живёт весь lifecycle) — для тестов и горячего перезапуска.
  @visibleForTesting
  Future<void> disposeAnalyticsBindings() async {
    _analyticsOnlineReaction?.call();
    _analyticsOnlineReaction = null;
    await _analyticsAuthSub?.cancel();
    _analyticsAuthSub = null;
  }

  /// Бэкенд принимает события только с мобильных платформ.
  static String? _analyticsPlatform() => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    _ => null,
  };

  /// Платформенные интеграции: App Shortcuts (иконка long-press) + Share-to-app
  /// (импорт рецептов по шарингу). Локализованные подписи берём из активной
  /// локали.
  Future<void> _initPlatformIntegrations(InjectionContainer container) async {
    try {
      final locale = Locale(container.getIt<LocalizationStore>().currentLocale);
      final l = lookupAppLocalizations(locale);
      await AppShortcutsService.instance.init(
        listsLabel: l.shortcutOpenLists,
        poraLabel: l.shortcutOpenPora,
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
