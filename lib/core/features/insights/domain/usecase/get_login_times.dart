import 'package:pora/core/features/insights/domain/repository/statistics_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetLoginTimesUseCase {
  const GetLoginTimesUseCase({required this.repository});
  final StatisticsRepository repository;

  Future<Either<Failure, List<DateTime>>> call() =>
      repository.getLoginTimes();
}
