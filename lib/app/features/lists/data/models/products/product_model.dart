import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/lists/data/models/converters/member_converter.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
@MemberConverter()
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.name,
    required super.id,
    required super.quantity,
    required super.unit,
    required super.priority,
    required super.urgent,
    required super.checked,
    required super.remindEveryDay,
    required super.addedBy,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
