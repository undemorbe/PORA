import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Тонкая обёртка над Firebase Analytics с типизированными событиями.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  bool get _ready => Firebase.apps.isNotEmpty;

  FirebaseAnalytics? get _analytics => _ready ? FirebaseAnalytics.instance : null;

  /// Включает сбор аналитики (в debug — выключаем, чтобы не шуметь).
  Future<void> init() async {
    try {
      // Собираем всегда (в т.ч. debug → виден в Firebase DebugView). Раньше в
      // debug сбор был выключен, из-за чего казалось, что аналитика «не работает».
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
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (e, s) {
      Logger.talker.warning('Analytics screen_view failed', e, s);
    }
  }

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e, s) {
      Logger.talker.warning('Analytics event "$name" failed', e, s);
    }
  }

  //! --- Типизированные события домена ---
  Future<void> logListOpened(String listId) =>
      _log('list_opened', {'list_id': listId});

  Future<void> logItemAdded({required String listId}) =>
      _log('item_added', {'list_id': listId});

  Future<void> logItemMarkedBought() => _log('item_marked_bought');

  Future<void> logAiChatOpened() => _log('ai_chat_opened');

  Future<void> logTipGenerated() => _log('ai_tip_generated');

  Future<void> logRecipeImport({required String source}) =>
      _log('recipe_import', {'source': source});

  Future<void> logSupportMessageSent() => _log('support_message_sent');

  Future<void> logAiConfigSaved({required bool custom}) =>
      _log('ai_config_saved', {'custom': custom.toString()});

  Future<void> logViewModeChanged({required bool grid}) =>
      _log('home_view_mode', {'grid': grid.toString()});
}
