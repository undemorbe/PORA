import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Единая точка аналитики. Типизированные события раздаются в три приёмника:
/// - Firebase Analytics (агрегаты по всем юзерам, DebugView);
/// - локальный [UsageTracker] (персональная статистика на экране Insights);
/// - [BackendEventSink] → `POST /api/analytics/events` (админ-панель).
///
/// В backend идут только client-only события (сессии, экраны, AI, рецепты,
/// поддержка, режим отображения). Доменные (товар/список) пишет сервер —
/// здесь их в backend не шлём, иначе двойной счёт.
///
/// Firebase поднимается отложенно (AppBootstrap) — до этого Firebase-часть
/// no-op'ит, а локальный трекер и backend-очередь копят события в буфере.
class AnalyticsService {
  AnalyticsService._()
    : _usageOverride = null,
      _backendOverride = null,
      _firebaseReady = _defaultFirebaseReady;

  @visibleForTesting
  AnalyticsService.test({
    required UsageTracker usage,
    required BackendEventSink backend,
    required this._firebaseReady,
  }) : _usageOverride = usage,
       _backendOverride = backend;

  static final AnalyticsService instance = AnalyticsService._();

  final UsageTracker? _usageOverride;
  final BackendEventSink? _backendOverride;
  final bool Function() _firebaseReady;

  static bool _defaultFirebaseReady() => Firebase.apps.isNotEmpty;

  UsageTracker get _usage => _usageOverride ?? UsageTracker.instance;

  BackendEventSink get _backend =>
      _backendOverride ?? BackendEventSink.instance;

  bool get _ready => _firebaseReady();

  FirebaseAnalytics? get _analytics =>
      _ready ? FirebaseAnalytics.instance : null;

  /// Включает сбор аналитики (в т.ч. debug → виден в Firebase DebugView).
  Future<void> init() async {
    try {
      await _analytics?.setAnalyticsCollectionEnabled(true);
      await logAppOpen();
    } catch (e, s) {
      Logger.talker.warning('Analytics init failed', e, s);
    }
  }

  Future<void> logAppOpen() async {
    try {
      await _analytics?.logAppOpen();
    } catch (_) {}
  }

  /// Экранное событие для навигации (см. PoraAnalyticsObserver).
  /// [countVisit] = false — возврат назад: Firebase-событие шлём, но в
  /// локальную статистику визитов не пишем.
  Future<void> logScreenView(
    String screenName, {
    bool countVisit = true,
  }) async {
    if (countVisit) {
      _usage.screenViewed(screenName);
      _backend.track('screen_view', {'screen': screenName});
    }
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (e, s) {
      Logger.talker.warning('Analytics screen_view failed', e, s);
    }
  }

  /// Firebase режет значения параметров длиннее 100 символов.
  static String? _short(String? value) {
    if (value == null || value.isEmpty) return null;
    return value.length <= 100 ? value : value.substring(0, 100);
  }

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e, s) {
      Logger.talker.warning('Analytics event "$name" failed', e, s);
    }
  }

  /// Начало сессии (холодный старт или возврат из фона). Firebase-аналог —
  /// `logAppOpen` в [init]; здесь — только backend.
  Future<void> logSessionStart() async {
    _backend.track('session_start');
  }

  //! --- Типизированные события домена ---
  Future<void> logListOpened(String listId) {
    _usage.listOpened();
    return _log('list_opened', {'list_id': listId});
  }

  Future<void> logListCreated({required bool shared}) {
    _usage.listCreated();
    return _log('list_created', {'shared': shared.toString()});
  }

  Future<void> logItemAdded({required String listId, String? section}) {
    _usage.itemAdded(section: section);
    return _log('item_added', {
      'list_id': listId,
      if (section != null && section.isNotEmpty) 'section': section,
    });
  }

  Future<void> logItemMarkedBought({String? name}) {
    _usage.itemBought(name: name);
    return _log('item_marked_bought');
  }

  Future<void> logItemDeleted() {
    _usage.itemDeleted();
    return _log('item_deleted');
  }

  Future<void> logAiChatOpened() {
    _backend.track('ai_chat_opened');
    return _log('ai_chat_opened');
  }

  Future<void> logAiMessageSent() {
    _usage.aiMessageSent();
    _backend.track('ai_message_sent');
    return _log('ai_message_sent');
  }

  /// Результат запроса к AI: [kind] — `chat`/`tip`/`recipe`, [latencyMs] —
  /// время ответа, [error] — тип Failure при ошибке. Позволяет видеть
  /// долю сбоев и медленные модели в Firebase.
  Future<void> logAiResponse({
    required String kind,
    required bool success,
    required int latencyMs,
    String? error,
  }) => _log('ai_response', {
    'kind': kind,
    'success': success.toString(),
    'latency_ms': latencyMs,
    'error': ?_short(error),
  });

  Future<void> logTipGenerated({required bool fromFallback}) {
    _backend.track('ai_tip_generated');
    return _log('ai_tip_generated', {'fallback': fromFallback.toString()});
  }

  Future<void> logRecipeImport({
    required String source,
    String? extractor,
    String? host,
    int? ingredients,
    int? durationMs,
  }) {
    _usage.recipeImported();
    _backend.track('recipe_import', {'source': source});
    return _log('recipe_import', {
      'source': source,
      'extractor': ?_short(extractor),
      'host': ?_short(host),
      'ingredients': ?ingredients,
      'duration_ms': ?durationMs,
    });
  }

  /// Неудачный импорт: [reason] — `invalid_url`/`http`/`no_ingredients`/
  /// `youtube`/`network`/…; по [host] видно, какие сайты чинить первыми.
  Future<void> logRecipeImportFailed({
    required String reason,
    String? host,
    int? durationMs,
  }) => _log('recipe_import_failed', {
    'reason': reason,
    'host': ?_short(host),
    'duration_ms': ?durationMs,
  });

  Future<void> logRecipeItemsAdded({required int count, int failed = 0}) =>
      _log('recipe_items_added', {'count': count, 'failed': failed});

  Future<void> logInsightsPeriodChanged(int days) =>
      _log('insights_period', {'days': days});

  Future<void> logSupportMessageSent() {
    _backend.track('support_message_sent');
    return _log('support_message_sent');
  }

  Future<void> logAiConfigSaved({required bool custom}) =>
      _log('ai_config_saved', {'custom': custom.toString()});

  Future<void> logViewModeChanged({required bool grid}) {
    _backend.track('view_mode_changed', {'grid': grid});
    return _log('home_view_mode', {'grid': grid.toString()});
  }
}
