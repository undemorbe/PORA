import 'package:pora/app/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class DeleteItemUseCase {
  final ItemsRepository repository;
  const DeleteItemUseCase({required this.repository});

  Future<Either<Failure, Success>> call({required String itemId}) =>
      repository.deleteItem(itemId: itemId);
}
