import 'package:pora/app/features/lists/data/models/products/product_model.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';

class ListSectionModel extends ListSectionEntity {
  const ListSectionModel({required super.name, required super.items});

  factory ListSectionModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List?;
    return ListSectionModel(
      name: json['name'] as String,
      items: (raw ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'items': items.whereType<ProductModel>().map((p) => p.toJson()).toList(),
  };
}
