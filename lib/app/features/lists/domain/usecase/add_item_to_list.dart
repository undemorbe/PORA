import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/domain/repository/lists_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class AddItemToListUseCase {
  final ListsRepository listsRepository;

  const AddItemToListUseCase({required this.listsRepository});

  Future<Either<Failure, Success>> call({
    required String lid,
    required ProductEntity product,
  }) async {
    return await listsRepository.addItemToList(lid: lid, product: product);
  }
}
