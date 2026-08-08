import 'package:pora/core/features/insights/data/datasource/statistics_remote.dart';
import 'package:pora/core/features/insights/data/models/login_times_model.dart';
import 'package:pora/core/features/insights/data/models/popular_product_model.dart';
import 'package:pora/core/features/insights/data/models/user_products_model.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/network/api_client/api_client.dart';

/// Retrofit-делегат. Все исключения нормализует `FailureMapper` — единый
/// Talker-логгинг + типизированный `ApiFailure` с error-code'ами.
class StatisticsRemoteImpl implements StatisticsRemote {
  const StatisticsRemoteImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Either<Failure, LoginTimesModel>> getLoginTimes() async {
    try {
      final res = await apiClient.getUserLoginTimes();
      return Right(res);
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, UserProductsModel>> getAllUserProducts() async {
    try {
      final res = await apiClient.getUserAllProducts();
      return Right(res);
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, PopularProductsModel>> getPopularProducts() async {
    try {
      final res = await apiClient.getUserPopularProducts();
      return Right(res);
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }
}
