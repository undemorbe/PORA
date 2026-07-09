import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/domain/entity/product.dart';
part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.emoji,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
