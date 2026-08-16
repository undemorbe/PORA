import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class MarkItemBoughtUseCase {
  final ItemsRepository repository;
  const MarkItemBoughtUseCase({required this.repository});

  Future<Either<Failure, Success>> call({
    required String itemId,
    required bool checked,
  }) => repository.markBought(itemId: itemId, checked: checked);
}
