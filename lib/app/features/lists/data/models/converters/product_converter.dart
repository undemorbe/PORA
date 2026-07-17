import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/lists/data/models/products/product_model.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';

class ProductConverter
    implements JsonConverter<ProductEntity, Map<String, dynamic>> {
  const ProductConverter();

  @override
  ProductEntity fromJson(Map<String, dynamic> json) =>
      ProductModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProductEntity object) =>
      (object as ProductModel).toJson();
}
