import 'package:pora/core/features/insights/data/datasource/statistics_remote.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/domain/repository/statistics_repository.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class StatisticsService implements StatisticsRepository {
  const StatisticsService({required this.remote});
  final StatisticsRemote remote;

  @override
  Future<Either<Failure, List<DateTime>>> getLoginTimes() async {
    final res = await remote.getLoginTimes();
    if (res.isLeft) return Left(res.left);
    return Right(res.right.toDateTimes());
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllUserProducts() async {
    final res = await remote.getAllUserProducts();
    if (res.isLeft) return Left(res.left);
    return Right(res.right.items);
  }

  @override
  Future<Either<Failure, List<PopularProductEntity>>>
      getPopularProducts() async {
    final res = await remote.getPopularProducts();
    if (res.isLeft) return Left(res.left);
    return Right(res.right.items.map((m) => m.toEntity()).toList());
  }
}
