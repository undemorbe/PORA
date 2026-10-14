import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/activity_chart.dart';
import 'package:pora/core/features/insights/presentation/widgets/due_soon_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/period_switch.dart';
import 'package:pora/core/features/insights/presentation/widgets/rhythm_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/stat_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/streak_card.dart';
import 'package:pora/core/features/insights/presentation/widgets/weekly_heatmap.dart';
import 'package:pora/core/internal/analytics/usage/usage_day.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';

Widget _wrap(Widget child, {String locale = 'ru'}) => MaterialApp(
  theme: PoraTheme.light,
  locale: Locale(locale),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: child,
    ),
  ),
);

UsageSummary _summary() {
  final now = DateTime(2026, 10, 6, 19);
  var today = UsageDay(
    date: DateTime(2026, 10, 6),
    opens: 2,
    added: 4,
    bought: 3,
  );
  for (var i = 0; i < 3; i++) {
    today = today.bumpHour(19);
  }
  return UsageSummary.compute(
    days: [
      today,
      UsageDay(date: DateTime(2026, 10, 5), opens: 1, added: 1).bumpHour(8),
    ],
    periodDays: 7,
    now: now,
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru');
    await initializeDateFormatting('en');
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(360, 1600);
    binding.platformDispatcher.views.first.devicePixelRatio = 1;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('streak uses ru plurals and shows best record', (tester) async {
    await tester.pumpWidget(_wrap(const StreakCard(days: 2, best: 11)));
    expect(find.text('2 дня подряд'), findsOneWidget);
    expect(find.text('Рекорд: 11'), findsOneWidget);
  });

  testWidgets('zero streak shows call to action', (tester) async {
    await tester.pumpWidget(_wrap(const StreakCard(days: 0), locale: 'en'));
    expect(find.text('0 days in a row'), findsOneWidget);
    expect(find.text('Open Pora every day to build a streak'), findsOneWidget);
  });

  testWidgets('period switch reports taps', (tester) async {
    int? picked;
    await tester.pumpWidget(
      _wrap(
        PeriodSwitch(
          periods: const [7, 30, 90],
          value: 30,
          onChanged: (v) => picked = v,
        ),
      ),
    );
    await tester.tap(find.text('90 дн.'));
    expect(picked, 90);
  });

  testWidgets('stat card renders trend', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatCard(number: '12', label: 'добавлено', delta: 25)),
    );
    expect(find.text('↑25%'), findsOneWidget);
  });

  testWidgets('summary blocks render without overflow on 360px', (
    tester,
  ) async {
    final s = _summary();
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            ActivityChart(points: s.series),
            RhythmCard(summary: s),
            WeeklyHeatmap(
              activity: s.activityByDay,
              now: DateTime(2026, 10, 6, 19),
            ),
            const DueSoonCard(
              items: [
                PopularProductEntity(
                  name: 'Молоко',
                  quantity: 9,
                  howOftenEnds: 4,
                  currentDay: 1.2,
                ),
                PopularProductEntity(
                  name: 'Очень длинное название продукта для проверки',
                  quantity: 3,
                  howOftenEnds: 10,
                  currentDay: 0.8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Чаще всего вы активны вечером'), findsOneWidget);
    expect(find.text('уже пора'), findsOneWidget);
    expect(find.text('через ~2 дн.'), findsOneWidget);
    expect(find.text('Активность за 4 недели'), findsOneWidget);
  });

  testWidgets('empty activity shows placeholder', (tester) async {
    final s = UsageSummary.compute(
      days: const [],
      periodDays: 7,
      now: DateTime(2026, 10, 6),
    );
    await tester.pumpWidget(_wrap(ActivityChart(points: s.series)));
    expect(find.text('За этот период активности пока нет'), findsOneWidget);
  });
}
