import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/domain/repository/statistics_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetPopularProductsUseCase {
  const GetPopularProductsUseCase({required this.repository});
  final StatisticsRepository repository;

  Future<Either<Failure, List<PopularProductEntity>>> call() =>
      repository.getPopularProducts();
}
