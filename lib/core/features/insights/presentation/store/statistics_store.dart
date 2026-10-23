import 'package:mobx/mobx.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/domain/usecase/get_all_user_products.dart';
import 'package:pora/core/features/insights/domain/usecase/get_login_times.dart';
import 'package:pora/core/features/insights/domain/usecase/get_popular_products.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/errors/failure.dart';

part 'statistics_store.g.dart';

class StatisticsStore = _StatisticsStoreBase with _$StatisticsStore;

/// Доступные периоды экрана Insights, дней.
const insightsPeriods = [7, 30, 90];

/// «Чемпион» покупок: сервер видит покупки со всех устройств, локальный
/// топ — запасной вариант. `null` — показывать нечего.
CountEntry? pickChampion(
  List<PopularProductEntity> server,
  List<CountEntry> local,
) {
  if (server.isNotEmpty && server.first.quantity > 0) {
    return CountEntry(server.first.name, server.first.quantity);
  }
  if (local.isNotEmpty) return local.first;
  return null;
}

/// Данные экрана Insights. Два источника:
/// - backend statistics API (логины, все продукты, популярные) — с
///   offline-кэшем в [HiveJsonCache];
/// - локальный [UsageTracker] (сессии, добавлено/куплено, часы, категории)
///   — реактивно, без сети.
abstract class _StatisticsStoreBase with Store {
  static const _loginsCacheKey = 'stats-logins-v1';
  static const _productsCacheKey = 'stats-products-v1';
  static const _popularCacheKey = 'stats-popular-v1';

  /// Повторный заход на экран чаще этого — без сетевого запроса.
  static const _refreshThrottle = Duration(minutes: 2);

  _StatisticsStoreBase({
    required this.loginTimesUseCase,
    required this.allProductsUseCase,
    required this.popularProductsUseCase,
    UsageTracker? usage,
    DateTime Function()? clock,
  }) : _usage = usage ?? UsageTracker.instance,
       _clock = clock ?? DateTime.now;

  final GetLoginTimesUseCase loginTimesUseCase;
  final GetAllUserProductsUseCase allProductsUseCase;
  final GetPopularProductsUseCase popularProductsUseCase;
  final UsageTracker _usage;
  final DateTime Function() _clock;

  bool _popularEndpointGone = false;
  bool _hydrated = false;
  DateTime? _lastLoadedAt;
  Future<void>? _inFlight;

  // --- период ---
  @observable
  int period = 30;

  // --- login times ---
  @observable
  ObservableList<DateTime> logins = ObservableList<DateTime>();

  @observable
  bool isLoginsLoading = false;

  @observable
  String? loginsError;

  // --- all user products ---
  @observable
  ObservableList<ProductEntity> allProducts = ObservableList<ProductEntity>();

  @observable
  bool isProductsLoading = false;

  @observable
  String? productsError;

  // --- popular products ---
  @observable
  ObservableList<PopularProductEntity> popularProducts =
      ObservableList<PopularProductEntity>();

  @observable
  bool isPopularLoading = false;

  @observable
  String? popularError;

  @computed
  bool get isLoading =>
      isLoginsLoading || isProductsLoading || isPopularLoading;

  /// Сводка пользования за выбранный [period]. Серверные логины
  /// подмешиваются как активные дни (покрывают другие устройства).
  @computed
  UsageSummary get usage => UsageSummary.compute(
    days: _usage.days.values,
    periodDays: period,
    now: _clock(),
    extraActiveDays: logins,
  );

  /// Продукты, которые по ритму покупок пора докупать (≥ 75% цикла).
  @computed
  List<PopularProductEntity> get dueSoon {
    final res = [
      for (final p in popularProducts)
        if (p.howOftenEnds > 0 && p.currentDay >= 0.75) p,
    ]..sort((a, b) => b.currentDay.compareTo(a.currentDay));
    return res.take(5).toList();
  }

  /// Категории (секции) всех продуктов за всё время; если сервер не отдал
  /// секции — локальные добавления за период.
  @computed
  List<CountEntry> get categories {
    final counts = <String, int>{};
    for (final p in allProducts) {
      final s = p.section.trim();
      if (s.isEmpty) continue;
      counts[s] = (counts[s] ?? 0) + 1;
    }
    if (counts.isEmpty) return usage.topSections;
    final res = [for (final e in counts.entries) CountEntry(e.key, e.value)]
      ..sort((a, b) => b.count.compareTo(a.count));
    return res.take(6).toList();
  }

  @computed
  int get uniqueProducts =>
      allProducts.map((p) => p.name.trim().toLowerCase()).toSet().length;

  @computed
  int get remindersCount =>
      allProducts.where((p) => (p.remindEveryDay ?? 0) > 0).length;

  @computed
  int get urgentCount => allProducts.where((p) => p.urgent).length;

  /// Самый покупаемый товар для `ChampionSection`, см. [pickChampion].
  @computed
  CountEntry? get champion =>
      pickChampion(popularProducts.toList(), usage.topBought);

  @action
  void setPeriod(int days) {
    if (!insightsPeriods.contains(days)) return;
    period = days;
  }

  /// Вход на экран: кэш → сеть. Повторные заходы в пределах
  /// [_refreshThrottle] сеть не дёргают; pull-to-refresh передаёт [force].
  /// Параллельные вызовы схлопываются в один.
  Future<void> loadAll({bool force = false}) {
    final last = _lastLoadedAt;
    if (!force &&
        last != null &&
        _clock().difference(last) < _refreshThrottle) {
      return Future.value();
    }
    return _inFlight ??= _loadAll().whenComplete(() => _inFlight = null);
  }

  Future<void> _loadAll() async {
    if (!_hydrated) {
      _hydrated = true;
      await _hydrateFromCache();
    }
    await Future.wait([loadLoginTimes(), loadAllProducts()]);
    await loadPopularProducts();
    _lastLoadedAt = _clock();
  }

  /// Один раз за жизнь store поднимаем снапшоты из кэша — дальше данные
  /// в памяти актуальнее.
  @action
  Future<void> _hydrateFromCache() async {
    final results = await Future.wait([
      HiveJsonCache.read(_loginsCacheKey),
      HiveJsonCache.read(_productsCacheKey),
      HiveJsonCache.read(_popularCacheKey),
    ]);
    final cachedLogins = results[0];
    if (cachedLogins is List && logins.isEmpty) {
      logins = ObservableList.of(
        cachedLogins
            .whereType<String>()
            .map(DateTime.tryParse)
            .whereType<DateTime>(),
      );
    }
    final cachedProducts = results[1];
    if (cachedProducts is List && allProducts.isEmpty) {
      allProducts = ObservableList.of(
        cachedProducts.whereType<Map>().map(_productFromJson).nonNulls,
      );
    }
    final cachedPopular = results[2];
    if (cachedPopular is List && popularProducts.isEmpty) {
      popularProducts = ObservableList.of(
        cachedPopular.whereType<Map>().map(_popularFromJson),
      );
    }
  }

  @action
  Future<void> loadLoginTimes() async {
    isLoginsLoading = true;
    loginsError = null;
    final res = await loginTimesUseCase();
    if (res.isRight) {
      logins = ObservableList.of(res.right);
      await HiveJsonCache.put(
        _loginsCacheKey,
        res.right.map((d) => d.toIso8601String()).toList(),
      );
    } else if (logins.isEmpty) {
      loginsError = res.left.message;
    }
    isLoginsLoading = false;
  }

  @action
  Future<void> loadAllProducts() async {
    isProductsLoading = true;
    productsError = null;
    final res = await allProductsUseCase();
    if (res.isRight) {
      allProducts = ObservableList.of(res.right);
      await HiveJsonCache.put(
        _productsCacheKey,
        res.right.map(_productToJson).toList(),
      );
    } else if (allProducts.isEmpty) {
      productsError = res.left.message;
    }
    isProductsLoading = false;
  }

  @action
  Future<void> loadPopularProducts() async {
    isPopularLoading = true;
    popularError = null;
    if (_popularEndpointGone) {
      popularProducts = ObservableList.of(_popularFromProducts(allProducts));
      isPopularLoading = false;
      return;
    }
    final res = await popularProductsUseCase();
    if (res.isRight) {
      final sorted = [...res.right]
        ..sort((a, b) => b.quantity.compareTo(a.quantity));
      popularProducts = ObservableList.of(sorted);
      await HiveJsonCache.put(
        _popularCacheKey,
        sorted
            .map(
              (p) => {
                'name': p.name,
                'quantity': p.quantity,
                'how-often-ends': p.howOftenEnds,
                'current-day': p.currentDay,
              },
            )
            .toList(),
      );
    } else {
      if (popularProducts.isEmpty && allProducts.isNotEmpty) {
        popularProducts = ObservableList.of(_popularFromProducts(allProducts));
      }
      final failure = res.left;
      _popularEndpointGone = failure is ApiFailure && failure.statusCode == 410;
      if (popularProducts.isEmpty && !_popularEndpointGone) {
        popularError = failure.message;
      }
    }
    isPopularLoading = false;
  }

  Map<String, dynamic> _productToJson(ProductEntity product) {
    if (product is ProductModel) return product.toJson();
    return {
      'name': product.name,
      'id': product.id,
      'section': product.section,
      'quantity': product.quantity,
      'unit': product.unit,
      'priority': product.priority,
      'urgent': product.urgent,
      'checked': product.checked,
      'remind-every-day': product.remindEveryDay,
    };
  }

  ProductModel? _productFromJson(Map<dynamic, dynamic> json) {
    try {
      return ProductModel.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  PopularProductEntity _popularFromJson(Map<dynamic, dynamic> json) {
    return PopularProductEntity(
      name: (json['name'] as String?) ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      howOftenEnds: (json['how-often-ends'] as num?)?.toInt() ?? 0,
      currentDay: (json['current-day'] as num?)?.toDouble() ?? 0,
    );
  }

  List<PopularProductEntity> _popularFromProducts(
    Iterable<ProductEntity> products,
  ) {
    final counts = <String, int>{};
    final names = <String, String>{};
    for (final product in products) {
      final name = product.name.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      names[key] = name;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in sorted.take(20))
        PopularProductEntity(
          name: names[entry.key]!,
          quantity: entry.value,
          howOftenEnds: 0,
          currentDay: 0,
        ),
    ];
  }
}
