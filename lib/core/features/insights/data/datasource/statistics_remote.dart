import 'package:pora/core/features/insights/data/models/login_times_model.dart';
import 'package:pora/core/features/insights/data/models/popular_product_model.dart';
import 'package:pora/core/features/insights/data/models/user_products_model.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Абстракция сетевого слоя statistics. Реализация — `StatisticsRemoteImpl`.
abstract class StatisticsRemote {
  Future<Either<Failure, LoginTimesModel>> getLoginTimes();
  Future<Either<Failure, UserProductsModel>> getAllUserProducts();
  Future<Either<Failure, PopularProductsModel>> getPopularProducts();
}
