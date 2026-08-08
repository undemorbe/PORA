import 'package:pora/core/features/insights/domain/entity/popular_product.dart';

/// DTO одного элемента `GET /user/statistics/popular-products`.
/// Wire-format: kebab-case per app convention.
class PopularProductModel {
  const PopularProductModel({
    required this.name,
    required this.quantity,
    required this.howOftenEnds,
    required this.currentDay,
  });

  final String name;
  final int quantity;
  final int howOftenEnds;
  final double currentDay;

  factory PopularProductModel.fromJson(Map<String, dynamic> json) {
    return PopularProductModel(
      name: (json['name'] as String?) ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      howOftenEnds: (json['how-often-ends'] as num?)?.toInt() ?? 0,
      currentDay: (json['current-day'] as num?)?.toDouble() ?? 0.0,
    );
  }

  PopularProductEntity toEntity() => PopularProductEntity(
        name: name,
        quantity: quantity,
        howOftenEnds: howOftenEnds,
        currentDay: currentDay,
      );
}

/// Wrapper `{ "items": [...] }`.
class PopularProductsModel {
  const PopularProductsModel({required this.items});

  final List<PopularProductModel> items;

  factory PopularProductsModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List?;
    return PopularProductsModel(
      items: (list ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PopularProductModel.fromJson)
          .toList(),
    );
  }
}
