import 'package:equatable/equatable.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';

abstract class ListSectionEntity extends Equatable {
  final String name;
  final String id;
  final List<ProductEntity> items;

  const ListSectionEntity({
    required this.name,
    required this.items,
    required this.id,
  });

  @override
  List<Object?> get props => [name, items];
}
