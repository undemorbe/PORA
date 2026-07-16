import 'package:pora/app/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

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
  }) =>
      repository.addItem(
        listId: listId,
        name: name,
        section: section,
        quantity: quantity,
        unit: unit,
        priority: priority,
        urgent: urgent,
        remindEveryDays: remindEveryDays,
      );
}
