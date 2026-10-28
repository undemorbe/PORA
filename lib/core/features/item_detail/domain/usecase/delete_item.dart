import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class DeleteItemUseCase {
  final ItemsRepository repository;
  const DeleteItemUseCase({required this.repository});

  Future<Either<Failure, Success>> call({required String itemId}) async {
    final res = await repository.deleteItem(itemId: itemId);
    if (res.isRight) AnalyticsService.instance.logItemDeleted();
    return res;
  }
}
