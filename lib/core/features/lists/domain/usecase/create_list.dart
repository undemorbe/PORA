import 'package:pora/core/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class CreateListUseCase {
  final ListsRepository listsRepository;

  const CreateListUseCase({required this.listsRepository});

  /// Возвращает id созданного списка.
  Future<Either<Failure, String>> call({
    required String name,
    String? fid,
  }) async {
    final res = await listsRepository.createList(name: name, fid: fid);
    if (res.isRight) {
      AnalyticsService.instance.logListCreated(shared: fid != null);
    }
    return res;
  }
}
