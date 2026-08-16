import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product.dart';

part 'brief_product_model.g.dart';

@JsonSerializable()
class BriefProductModel extends BriefProductEntity {
  const BriefProductModel({required super.title, super.leading});

  factory BriefProductModel.fromJson(Map<String, dynamic> json) =>
      _$BriefProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$BriefProductModelToJson(this);

  factory BriefProductModel.fromEntity(BriefProductEntity entity) {
    return BriefProductModel(title: entity.title, leading: entity.leading);
  }
}
