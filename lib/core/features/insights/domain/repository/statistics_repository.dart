import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Абстракция статистики пользователя. Скрывает транспорт (Retrofit/иное) —
/// UI/usecase работают только с этим контрактом.
abstract class StatisticsRepository {
  /// Юзер-логины (по обновлению refresh-токена) за последние 90 дней.
  /// Порядок убывающий (свежие первыми).
  Future<Either<Failure, List<DateTime>>> getLoginTimes();

  /// ВСЕ продукты, когда-либо добавленные юзером. Формат совпадает
  /// с `ProductEntity` из `lists`.
  Future<Either<Failure, List<ProductEntity>>> getAllUserProducts();

  /// Популярные продукты. Порядок бэкенд не гарантирует — сортирует store.
  Future<Either<Failure, List<PopularProductEntity>>> getPopularProducts();
}
