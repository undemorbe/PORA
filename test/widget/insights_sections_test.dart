import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/categories_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/champion_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/due_soon_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/engagement_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/insights_header.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/kpi_grid.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/popular_section.dart';
import 'package:pora/core/features/insights/presentation/widgets/sections/top_bought_section.dart';
import 'package:pora/core/internal/analytics/usage/usage_day.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: PoraTheme.light,
  locale: const Locale('ru'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

PopularProductEntity _popular(String name, int quantity) =>
    PopularProductEntity(
      name: name,
      quantity: quantity,
      howOftenEnds: 0,
      currentDay: 0,
    );

void main() {
  testWidgets('empty sections collapse', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ChampionSection(champion: null),
            TopBoughtSection(top: [CountEntry('Хлеб', 1)]),
            CategoriesSection(categories: []),
            DueSoonSection(items: []),
          ],
        ),
      ),
    );
    expect(find.byType(SizedBox), findsWidgets);
    expect(find.text('Хлеб'), findsNothing);
    expect(find.text('ПОРА ДОКУПИТЬ'), findsNothing);
  });

  testWidgets('champion and top bought render names', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ChampionSection(champion: CountEntry('Молоко', 12)),
            TopBoughtSection(
              top: [CountEntry('Хлеб', 4), CountEntry('Сыр', 2)],
            ),
          ],
        ),
      ),
    );
    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('Хлеб'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
  });

  testWidgets('popular section: loading, error, list', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PopularSection(products: [], isLoading: true, errorMessage: null),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const PopularSection(
          products: [],
          isLoading: false,
          errorMessage: 'Нет сети',
        ),
      ),
    );
    expect(find.text('Нет сети'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        PopularSection(
          products: [_popular('Молоко', 5)],
          isLoading: false,
          errorMessage: null,
        ),
      ),
    );
    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('×5'), findsOneWidget);
  });

  testWidgets('header back button fires callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(InsightsHeader(title: 'Инсайты', onBack: () => tapped = true)),
    );
    await tester.tap(find.byType(GestureDetector).first);
    expect(tapped, isTrue);
    expect(find.text('Инсайты'), findsOneWidget);
  });

  testWidgets('kpi grid, engagement and due soon render data', (tester) async {
    final summary = UsageSummary.compute(
      days: [UsageDay(date: DateTime(2026, 10, 6), opens: 1, added: 4)],
      periodDays: 7,
      now: DateTime(2026, 10, 6, 19),
    );
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            InsightsKpiGrid(summary: summary),
            EngagementSection(
              summary: summary,
              uniqueProducts: 17,
              remindersCount: 3,
              urgentCount: 2,
            ),
            const DueSoonSection(
              items: [
                PopularProductEntity(
                  name: 'Кофе',
                  quantity: 3,
                  howOftenEnds: 7,
                  currentDay: 0.9,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.text('добавлено'), findsOneWidget);
    expect(find.text('ЗА ВСЁ ВРЕМЯ'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(find.text('ПОРА ДОКУПИТЬ'), findsOneWidget);
    expect(find.text('Кофе'), findsOneWidget);
  });
}
