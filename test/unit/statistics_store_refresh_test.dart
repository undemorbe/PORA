import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/domain/repository/statistics_repository.dart';
import 'package:pora/core/features/insights/domain/usecase/get_all_user_products.dart';
import 'package:pora/core/features/insights/domain/usecase/get_login_times.dart';
import 'package:pora/core/features/insights/domain/usecase/get_popular_products.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

import '../helpers/fake_local_db.dart';

class _CountingRepository implements StatisticsRepository {
  int productCalls = 0;

  @override
  Future<Either<Failure, List<DateTime>>> getLoginTimes() async => Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllUserProducts() async {
    productCalls++;
    return Right([]);
  }

  @override
  Future<Either<Failure, List<PopularProductEntity>>>
  getPopularProducts() async => Right([]);
}

/// Вкладка Pora не должна показывать старые KPI после своих же изменений.
void main() {
  late Directory tmp;
  late _CountingRepository repo;
  late UsageTracker tracker;
  late StatisticsStore store;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_stats_refresh_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-cache');
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    await HiveJsonCache.clear();
    repo = _CountingRepository();
    tracker = UsageTracker();
    await tracker.attach(FakeLocalDB());
    store = StatisticsStore(
      loginTimesUseCase: GetLoginTimesUseCase(repository: repo),
      allProductsUseCase: GetAllUserProductsUseCase(repository: repo),
      popularProductsUseCase: GetPopularProductsUseCase(repository: repo),
      usage: tracker,
    );
  });

  tearDown(() => store.dispose());

  test('repeated loadAll within throttle skips the network', () async {
    await store.loadAll();
    await store.loadAll();
    expect(repo.productCalls, 1);
  });

  test('a local item change makes the next loadAll refetch', () async {
    await store.loadAll();
    tracker.itemAdded(section: 'Молочное');
    await store.loadAll();
    expect(repo.productCalls, 2);

    tracker.itemBought(name: 'Молоко');
    await store.loadAll();
    expect(repo.productCalls, 3);

    // Без новых изменений — снова throttle.
    await store.loadAll();
    expect(repo.productCalls, 3);
  });

  test('force bypasses the throttle', () async {
    await store.loadAll();
    await store.loadAll(force: true);
    expect(repo.productCalls, 2);
  });
}
