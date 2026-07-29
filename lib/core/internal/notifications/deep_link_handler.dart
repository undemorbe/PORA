import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/router/app_router.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';

/// Роутит push-payload (`RemoteMessage.data`) в auto_route.
///
/// Payload contract (backend кладёт в data):
///   ```
///   {
///     "type": "urgent",           // тип события (только для UI-эмодзи/цвета)
///     "screen": "notifications",  // куда роутить
///     "family-id": "...",         // опционально
///     "list-id": "...",           // требуется для screen=list
///     "item-id": "..."            // опционально, будущее (ItemDetail)
///   }
///   ```
/// Reminder и обычные notifications имеют одинаковый `data` — отличаются
/// только `title`/`body`, поэтому обрабатываются одним кодом.
///
/// Supported `screen` values:
///   - `notifications` → NotificationsRoute
///   - `predictions` / `pora` → PredictionsRoute (tab)
///   - `order` → OrderRoute (tab)
///   - `settings` / `profile` → SettingsRoute (tab)
///   - `families` → FamiliesRoute (tab)
///   - `list` → ListRoute(listId=data['list-id'])
///
/// Cold-start: если роутер ещё не готов или пользователь не залогинен,
/// payload кладётся в [_pending] и раскрывается через [flushPending].
class DeepLinkHandler {
  DeepLinkHandler._();
  static final DeepLinkHandler instance = DeepLinkHandler._();

  Map<String, dynamic>? _pending;
  bool _subscribedToAuth = false;

  /// Однократно подписаться на AuthState, чтобы pending раскрывался
  /// сразу после логина / готовности гвардов.
  void bindToAuth() {
    if (_subscribedToAuth) return;
    final auth = _tryGet<AuthState>();
    if (auth == null) return;
    _subscribedToAuth = true;
    auth.stream.listen((status) {
      if (status == AuthStatus.authenticated) flushPending();
    });
  }

  /// Основная точка. Вызывается из NotificationService.
  Future<void> handle(Map<String, dynamic> data) async {
    if (data.isEmpty) return;

    final auth = _tryGet<AuthState>();
    final router = _tryGet<AppRouter>();

    if (router == null || auth == null || !auth.isAuthenticated) {
      _pending = data;
      Logger.talker.info('DeepLink pending (router/auth not ready): $data');
      return;
    }

    await _route(router, data);
  }

  /// Вызвать после установки авторизации / готовности роутера
  /// (например из auth_store после setAuthenticated или из splash).
  Future<void> flushPending() async {
    final data = _pending;
    if (data == null) return;
    _pending = null;
    await handle(data);
  }

  Future<void> _route(AppRouter router, Map<String, dynamic> data) async {
    final screen = data['screen']?.toString();
    Logger.talker.info('DeepLink handling screen="$screen" data=$data');

    switch (screen) {
      case 'notifications':
        await router.push(const NotificationsRoute());
        return;
      case 'predictions':
      case 'pora':
        await router.push(const PredictionsRoute());
        return;
      case 'order':
        await router.push(const OrderRoute());
        return;
      case 'settings':
      case 'profile':
        await router.push(const SettingsRoute());
        return;
      case 'families':
        await router.push(const FamiliesRoute());
        return;
      case 'list':
        // Контракт backend: ключ `list-id` (hyphen).
        final listId = (data['list-id'] ?? data['listId'])?.toString();
        if (listId == null || listId.isEmpty) {
          Logger.talker.warning('DeepLink screen=list without list-id');
          await router.push(const NotificationsRoute());
          return;
        }
        await router.push(ListRoute(listId: listId));
        return;
      default:
        Logger.talker.warning('DeepLink: unknown screen "$screen"');
        await router.push(const NotificationsRoute());
    }
  }

  T? _tryGet<T extends Object>() {
    try {
      return GetIt.I.isRegistered<T>() ? GetIt.I<T>() : null;
    } catch (_) {
      return null;
    }
  }
}
