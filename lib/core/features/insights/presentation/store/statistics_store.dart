import 'package:mobx/mobx.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/features/insights/domain/usecase/get_all_user_products.dart';
import 'package:pora/core/features/insights/domain/usecase/get_login_times.dart';
import 'package:pora/core/features/insights/domain/usecase/get_popular_products.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';

part 'statistics_store.g.dart';

class StatisticsStore = _StatisticsStoreBase with _$StatisticsStore;

/// Store инсайтов. Три независимых источника, каждый со своим loading/error
/// стейтом — UI'у важно показать секцию как только её данные пришли, не ждать
/// всё разом.
abstract class _StatisticsStoreBase with Store {
  _StatisticsStoreBase({
    required this.loginTimesUseCase,
    required this.allProductsUseCase,
    required this.popularProductsUseCase,
  });

  final GetLoginTimesUseCase loginTimesUseCase;
  final GetAllUserProductsUseCase allProductsUseCase;
  final GetPopularProductsUseCase popularProductsUseCase;

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
    await Future.wait([
      loadLoginTimes(),
      loadAllProducts(),
      loadPopularProducts(),
    ]);
  }

  @action
  Future<void> loadLoginTimes() async {
    isLoginsLoading = true;
    loginsError = null;
    final res = await loginTimesUseCase();
    if (res.isRight) {
      logins = ObservableList.of(res.right);
      await HiveJsonCache.put(
        'stats-logins-v1',
        res.right.map((d) => d.toIso8601String()).toList(),
      );
    } else {
      // Fallback — читаем cache.
      final cached = await HiveJsonCache.read('stats-logins-v1');
      if (cached is List) {
        logins = ObservableList.of(
          cached
              .whereType<String>()
              .map(DateTime.tryParse)
              .whereType<DateTime>()
              .toList(),
        );
      } else {
        loginsError = res.left.message;
      }
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
    } else {
      productsError = res.left.message;
    }
    isProductsLoading = false;
  }

  @action
  Future<void> loadPopularProducts() async {
    isPopularLoading = true;
    popularError = null;
    final res = await popularProductsUseCase();
    if (res.isRight) {
      popularProducts = ObservableList.of(res.right);
      // Cache snapshot.
      await HiveJsonCache.put(
        'stats-popular-v1',
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
      final cached = await HiveJsonCache.read('stats-popular-v1');
      if (cached is List) {
        popularProducts = ObservableList.of(
          cached.whereType<Map>().map((m) {
            return PopularProductEntity(
              name: (m['name'] as String?) ?? '',
              quantity: (m['quantity'] as num?)?.toInt() ?? 0,
              howOftenEnds: (m['how-often-ends'] as num?)?.toInt() ?? 0,
              currentDay: (m['current-day'] as num?)?.toDouble() ?? 0,
            );
          }).toList(),
        );
      } else {
        popularError = res.left.message;
      }
    }
    isPopularLoading = false;
  }
}
