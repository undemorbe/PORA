import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';

import '../helpers/fake_local_db.dart';

void main() {
  late BackendEventSink backend;
  late UsageTracker usage;
  late AnalyticsService analytics;

  setUp(() {
    backend = BackendEventSink(random: Random(1));
    usage = UsageTracker();
    analytics = AnalyticsService.test(
      usage: usage,
      backend: backend,
      firebaseReady: () => false,
    );
  });

  List<String> sent() => [for (final e in backend.pending) e.name];

  test('domain events stay local — the server records them itself', () async {
    await analytics.logItemAdded(listId: 'l1', section: 'Овощи');
    await analytics.logItemMarkedBought(name: 'Томаты');
    await analytics.logItemDeleted();
    await analytics.logListCreated(shared: true);
    await analytics.logListOpened('l1');

    expect(sent(), isEmpty);
  });

  test('non-whitelisted client events are not sent to backend', () async {
    await analytics.logAiResponse(kind: 'chat', success: true, latencyMs: 10);
    await analytics.logRecipeImportFailed(reason: 'http', host: 'a.com');
    await analytics.logRecipeItemsAdded(count: 3);
    await analytics.logInsightsPeriodChanged(7);
    await analytics.logAiConfigSaved(custom: true);

    expect(sent(), isEmpty);
  });

  test('client-only events go to backend with whitelisted props', () async {
    await analytics.logSessionStart();
    await analytics.logScreenView('InsightsRoute');
    await analytics.logScreenView('HomeRoute', countVisit: false);
    await analytics.logAiChatOpened();
    await analytics.logAiMessageSent();
    await analytics.logTipGenerated(fromFallback: false);
    // запасной локальный совет — не AI-ответ, на сервер не идёт
    await analytics.logTipGenerated(fromFallback: true);
    await analytics.logRecipeImport(
      source: 'youtube',
      extractor: 'yt',
      host: 'youtube.com',
      ingredients: 5,
      durationMs: 1200,
    );
    await analytics.logSupportMessageSent();
    await analytics.logViewModeChanged(grid: true);

    expect(sent(), [
      'session_start',
      'screen_view',
      'ai_chat_opened',
      'ai_message_sent',
      'ai_tip_generated',
      'recipe_import',
      'support_message_sent',
      'view_mode_changed',
    ]);
    for (final i in [0, 2, 3, 4, 6]) {
      expect(backend.pending[i].props, isEmpty, reason: sent()[i]);
    }

    // Server whitelist: screen_view.screen string, recipe_import.source
    // string, view_mode_changed.grid bool — exact keys and types.
    final screen = backend.pending[1].props;
    expect(screen, {'screen': 'InsightsRoute'});
    expect(screen['screen'], isA<String>());

    final recipe = backend.pending[5].props;
    expect(recipe, {'source': 'youtube'});
    expect(recipe['source'], isA<String>());

    final viewMode = backend.pending[7].props;
    expect(viewMode, {'grid': true});
    expect(viewMode['grid'], isA<bool>());
  });

  test('local tracker still receives fanned-out client events', () async {
    final clock = DateTime(2026, 10, 6, 10);
    usage = UsageTracker(clock: () => clock);
    analytics = AnalyticsService.test(
      usage: usage,
      backend: backend,
      firebaseReady: () => false,
    );
    await analytics.logAiMessageSent();
    await analytics.logRecipeImport(source: 'web');
    await analytics.logScreenView('InsightsRoute');
    await analytics.logScreenView('HomeRoute', countVisit: false);
    await usage.attach(FakeLocalDB());

    final today = usage.days['2026-10-06']!;
    expect(today.aiMessages, 1);
    expect(today.recipes, 1);
    expect(today.screens, {'InsightsRoute': 1});
    expect(sent(), ['ai_message_sent', 'recipe_import', 'screen_view']);
  });
}
