import 'package:mobx/mobx.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/features/insights/domain/usecase/get_all_user_products.dart';
import 'package:pora/core/features/insights/domain/usecase/get_login_times.dart';
import 'package:pora/core/features/insights/domain/usecase/get_popular_products.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';

part 'statistics_store.g.dart';

class StatisticsStore = _StatisticsStoreBase with _$StatisticsStore;

abstract class _StatisticsStoreBase with Store {
  static const _loginsCacheKey = 'stats-logins-v1';
  static const _productsCacheKey = 'stats-products-v1';
  static const _popularCacheKey = 'stats-popular-v1';

  _StatisticsStoreBase({
    required this.loginTimesUseCase,
    required this.allProductsUseCase,
    required this.popularProductsUseCase,
  });

  final GetLoginTimesUseCase loginTimesUseCase;
  final GetAllUserProductsUseCase allProductsUseCase;
  final GetPopularProductsUseCase popularProductsUseCase;
  bool _popularEndpointGone = false;

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

  /// Streak дней подряд — computed из логинов.
  /// Считаем уникальные дни по локальной таймзоне; streak прерывается как
  /// только между двумя соседними днями появляется gap.
  @computed
  int get streakDays {
    if (logins.isEmpty) return 0;
    final uniqueDays = <DateTime>{};
    for (final t in logins) {
      final local = t.toLocal();
      uniqueDays.add(DateTime(local.year, local.month, local.day));
    }
    final sorted = uniqueDays.toList()..sort((a, b) => b.compareTo(a));
    var streak = 1;
    for (var i = 0; i < sorted.length - 1; i++) {
      final gap = sorted[i].difference(sorted[i + 1]).inDays;
      if (gap == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Всё сразу — вызывается на входе в insights экран.
  @action
  Future<void> loadAll() async {
    await Future.wait([loadLoginTimes(), loadAllProducts()]);
    await loadPopularProducts();
  }

  @action
  Future<void> loadLoginTimes() async {
    isLoginsLoading = true;
    loginsError = null;
    final cached = await HiveJsonCache.read(_loginsCacheKey);
    if (cached is List) {
      logins = ObservableList.of(
        cached
            .whereType<String>()
            .map(DateTime.tryParse)
            .whereType<DateTime>()
            .toList(),
      );
    }
    final res = await loginTimesUseCase();
    if (res.isRight) {
      logins = ObservableList.of(res.right);
      await HiveJsonCache.put(
        _loginsCacheKey,
        res.right.map((d) => d.toIso8601String()).toList(),
      );
    } else {
      if (logins.isEmpty) {
        loginsError = res.left.message;
      }
    }
    isLoginsLoading = false;
  }

  @action
  Future<void> loadAllProducts() async {
    isProductsLoading = true;
    productsError = null;
    final cached = await HiveJsonCache.read(_productsCacheKey);
    if (cached is List) {
      allProducts = ObservableList.of(
        cached.whereType<Map>().map(_productFromJson).whereType<ProductModel>(),
      );
    }
    final res = await allProductsUseCase();
    if (res.isRight) {
      allProducts = ObservableList.of(res.right);
      await HiveJsonCache.put(
        _productsCacheKey,
        res.right.map(_productToJson).toList(),
      );
    } else {
      if (allProducts.isEmpty) productsError = res.left.message;
    }
    isProductsLoading = false;
  }

  @action
  Future<void> loadPopularProducts() async {
    isPopularLoading = true;
    popularError = null;
    final cached = await HiveJsonCache.read(_popularCacheKey);
    if (cached is List) {
      popularProducts = ObservableList.of(
        cached.whereType<Map>().map(_popularFromJson).toList(),
      );
    }
    if (_popularEndpointGone) {
      popularProducts = ObservableList.of(_popularFromProducts(allProducts));
      isPopularLoading = false;
      return;
    }
    final res = await popularProductsUseCase();
    if (res.isRight) {
      popularProducts = ObservableList.of(res.right);
      // Cache snapshot.
      await HiveJsonCache.put(
        _popularCacheKey,
        res.right
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
      final isEndpointGone =
          res.left is ApiFailure && (res.left as ApiFailure).statusCode == 410;
      _popularEndpointGone = isEndpointGone;
      if (popularProducts.isEmpty && !isEndpointGone) {
        popularError = res.left.message;
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
