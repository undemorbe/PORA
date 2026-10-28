import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/backend/analytics_event.dart';

void main() {
  test('uuidV4 has RFC 4122 v4 shape and is unique', () {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final ids = {for (var i = 0; i < 200; i++) uuidV4(Random(i))};
    expect(ids, hasLength(200));
    expect(ids.every(pattern.hasMatch), isTrue);
  });

  test('toJson uses kebab-case keys and UTC ISO time', () {
    final event = AnalyticsEvent(
      id: 'id-1',
      name: 'recipe_import',
      props: const {'source': 'youtube'},
      occurredAt: DateTime.utc(2026, 10, 15, 10),
    );

    expect(event.toJson(platform: 'ios', appVersion: '1.4.0'), {
      'id': 'id-1',
      'name': 'recipe_import',
      'props': {'source': 'youtube'},
      'platform': 'ios',
      'app-version': '1.4.0',
      'occurred-at': '2026-10-15T10:00:00.000Z',
    });
  });

  test('storage roundtrip keeps fields; garbage is skipped', () {
    final event = AnalyticsEvent(
      id: 'id-2',
      name: 'view_mode_changed',
      props: const {'grid': true},
      occurredAt: DateTime.utc(2026, 10, 15, 9, 30),
    );

    final restored = AnalyticsEvent.fromStorage(event.toStorage());
    expect(restored?.id, 'id-2');
    expect(restored?.props, {'grid': true});
    expect(restored?.occurredAt, DateTime.utc(2026, 10, 15, 9, 30));

    expect(AnalyticsEvent.fromStorage('nope'), isNull);
    expect(AnalyticsEvent.fromStorage({'id': 1}), isNull);
  });
}
