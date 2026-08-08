import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Абстракция статистики пользователя. Скрывает транспорт (Retrofit/иное) —
/// UI/usecase работают только с этим контрактом.
abstract class StatisticsRepository {
  /// Все юзер-логины (по обновлению refresh-токена) за последнюю неделю.
  /// Порядок убывающий (свежие первыми).
  Future<Either<Failure, List<DateTime>>> getLoginTimes();

  /// ВСЕ продукты, когда-либо добавленные юзером. Формат совпадает
  /// с `ProductEntity` из `lists`.
  Future<Either<Failure, List<ProductEntity>>> getAllUserProducts();

  /// Популярные продукты — отсортированы бэкендом по quantity убыванию.
  Future<Either<Failure, List<PopularProductEntity>>> getPopularProducts();
}
