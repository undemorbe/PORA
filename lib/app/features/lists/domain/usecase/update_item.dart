import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class UpdateItemUseCase {
  final ListsRepository repository;

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
  }) {
    return repository.updateItem(
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
}
