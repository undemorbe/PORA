import 'package:equatable/equatable.dart';
import 'package:pora/app/features/families/domain/entity/product.dart';

/// Список покупок семьи. У одной семьи их может быть несколько.
/// [highPriorityProducts] — превью срочных позиций (отдаётся бэкендом).
abstract class ShoppingListEntity extends Equatable {
  final String id;
  final String name;
  final List<ProductEntity> highPriorityProducts;

  const ShoppingListEntity({
    required this.id,
    required this.name,
    required this.highPriorityProducts,
  });

  @override
  List<Object?> get props => [id, name, highPriorityProducts];
}
