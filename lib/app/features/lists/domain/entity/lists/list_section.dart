import 'package:equatable/equatable.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';

abstract class ListSectionEntity extends Equatable {
  final String name;
  final List<ProductEntity> items;

  const ListSectionEntity({
    required this.name,
    required this.items,
  });

  @override
  List<Object?> get props => [name, items];
}
