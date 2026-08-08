import 'package:pora/core/features/lists/data/models/products/product_model.dart';

/// DTO ответа `GET /user/statistics/products`.
/// Body: `{ "items": [ProductModel, ...] }` — весь исторический набор
/// продуктов юзера в стандартном product-формате из lists.
class UserProductsModel {
  const UserProductsModel({required this.items});

  final List<ProductModel> items;

  factory UserProductsModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List?;
    return UserProductsModel(
      items: (list ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList(),
    );
  }
}
