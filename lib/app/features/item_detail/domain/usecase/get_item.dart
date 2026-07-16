import 'package:pora/app/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class GetItemUseCase {
  final ItemsRepository repository;
  const GetItemUseCase({required this.repository});

  Future<Either<Failure, ProductEntity>> call({required String itemId}) =>
      repository.getItem(itemId: itemId);
}
