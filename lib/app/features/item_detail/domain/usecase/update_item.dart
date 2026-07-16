import 'package:pora/app/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class UpdateItemUseCase {
  final ItemsRepository repository;
  const UpdateItemUseCase({required this.repository});

  Future<Either<Failure, Success>> call({
    required String itemId,
    required String name,
    required String section,
    required int quantity,
    required String unit,
    required int priority,
    required bool urgent,
    required int? remindEveryDays,
  }) =>
      repository.updateItem(
        itemId: itemId,
        name: name,
        section: section,
        quantity: quantity,
        unit: unit,
        priority: priority,
        urgent: urgent,
        remindEveryDays: remindEveryDays,
      );
}
