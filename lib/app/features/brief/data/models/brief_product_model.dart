import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product.dart';

part 'brief_product_model.g.dart';

@JsonSerializable(includeIfNull: true)
class BriefProductModel extends BriefProductEntity {
  const BriefProductModel({required super.title, super.leading});

  factory BriefProductModel.fromJson(Map<String, dynamic> json) =>
      _$BriefProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$BriefProductModelToJson(this);
}
