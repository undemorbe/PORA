import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Единая точка аналитики: типизированные события уходят в Firebase
/// Analytics (агрегаты по всем юзерам) и в локальный [UsageTracker]
/// (персональная статистика на экране Insights).
///
/// Firebase поднимается отложенно (AppBootstrap) — до этого Firebase-часть
/// no-op'ит, а локальный трекер копит события в буфере.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  UsageTracker get _usage => UsageTracker.instance;

  bool get _ready => Firebase.apps.isNotEmpty;

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
    if (countVisit) _usage.screenViewed(screenName);
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

  Future<void> logAiChatOpened() => _log('ai_chat_opened');

  Future<void> logAiMessageSent() {
    _usage.aiMessageSent();
    return _log('ai_message_sent');
  }

  Future<void> logTipGenerated() => _log('ai_tip_generated');

  Future<void> logRecipeImport({required String source}) {
    _usage.recipeImported();
    return _log('recipe_import', {'source': source});
  }

  Future<void> logInsightsPeriodChanged(int days) =>
      _log('insights_period', {'days': days});

  Future<void> logSupportMessageSent() => _log('support_message_sent');

  Future<void> logAiConfigSaved({required bool custom}) =>
      _log('ai_config_saved', {'custom': custom.toString()});

  Future<void> logViewModeChanged({required bool grid}) =>
      _log('home_view_mode', {'grid': grid.toString()});
}
