import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class AddItemUseCase {
  final ItemsRepository repository;
  const AddItemUseCase({required this.repository});

  /// Возвращает id созданного товара.
  Future<Either<Failure, String>> call({
    required String listId,
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  }) async {
    final res = await repository.addItem(
      listId: listId,
      name: name,
      section: section,
      quantity: quantity,
      unit: unit,
      priority: priority,
      urgent: urgent,
      remindEveryDays: remindEveryDays,
    );
    if (res.isRight) {
      AnalyticsService.instance.logItemAdded(listId: listId, section: section);
    }
    return res;
  }
}
