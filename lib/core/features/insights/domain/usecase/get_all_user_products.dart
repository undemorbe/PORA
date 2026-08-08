import 'package:pora/core/features/insights/domain/repository/statistics_repository.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetAllUserProductsUseCase {
  const GetAllUserProductsUseCase({required this.repository});
  final StatisticsRepository repository;

  Future<Either<Failure, List<ProductEntity>>> call() =>
      repository.getAllUserProducts();
}
