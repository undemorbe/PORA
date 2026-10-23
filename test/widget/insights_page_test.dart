import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/domain/repository/statistics_repository.dart';
import 'package:pora/core/features/insights/domain/usecase/get_all_user_products.dart';
import 'package:pora/core/features/insights/domain/usecase/get_login_times.dart';
import 'package:pora/core/features/insights/domain/usecase/get_popular_products.dart';
import 'package:pora/core/features/insights/presentation/screen/insights_screen.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';

class _FakeStatisticsRepository implements StatisticsRepository {
  @override
  Future<Either<Failure, List<DateTime>>> getLoginTimes() async => Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllUserProducts() async =>
      Right([]);

  @override
  Future<Either<Failure, List<PopularProductEntity>>>
  getPopularProducts() async => Right(const [
    PopularProductEntity(
      name: 'Молоко',
      quantity: 12,
      howOftenEnds: 0,
      currentDay: 0,
    ),
    PopularProductEntity(
      name: 'Кофе',
      quantity: 4,
      howOftenEnds: 7,
      currentDay: 0.9,
    ),
  ]);
}

/// Композиция экрана целиком: store из GetIt + секции через Observer.
void main() {
  late Directory tmp;

  setUpAll(() async {
    await initializeDateFormatting('ru');
    tmp = Directory.systemTemp.createTempSync('pora_insights_page_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-cache');
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    await HiveJsonCache.clear();
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(400, 4000);
    binding.platformDispatcher.views.first.devicePixelRatio = 1;
  });

  tearDown(() async {
    await GetIt.I.reset();
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('InsightsPage composes sections from store data', (tester) async {
    final repo = _FakeStatisticsRepository();
    final store = StatisticsStore(
      loginTimesUseCase: GetLoginTimesUseCase(repository: repo),
      allProductsUseCase: GetAllUserProductsUseCase(repository: repo),
      popularProductsUseCase: GetPopularProductsUseCase(repository: repo),
      usage: UsageTracker(),
    );
    GetIt.I.registerSingleton<StatisticsStore>(store);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PoraTheme.light,
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const InsightsPage(),
        ),
      );
      // initState уже запустил loadAll — это тот же in-flight future.
      await store.loadAll();
    });
    await tester.pumpAndSettle();

    expect(find.text('Инсайты'), findsOneWidget);
    expect(find.text('ПОРА ДОКУПИТЬ'), findsOneWidget);
    expect(find.text('ЧАСТО ПОКУПАЕТЕ'), findsOneWidget);
    expect(find.text('ЗА ВСЁ ВРЕМЯ'), findsOneWidget);
    // Чемпион (сервер) + строка популярных.
    expect(find.text('Молоко'), findsNWidgets(2));
    expect(find.text('×12'), findsOneWidget);
    // Локальный топ пуст → секция скрыта; категорий нет → скрыта.
    expect(find.text('ЧАЩЕ ВСЕГО ПОКУПАЛИ ЗА ПЕРИОД'), findsNothing);
    expect(find.text('Что вы добавляете'), findsNothing);
  });
}
