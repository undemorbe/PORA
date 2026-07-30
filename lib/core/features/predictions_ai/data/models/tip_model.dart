import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/tip.dart';

part 'tip_model.g.dart';

@JsonSerializable()
class TipModel extends TipEntity {
  const TipModel({required super.title, required super.subtitle});

  factory TipModel.fromJson(Map<String, dynamic> json) =>
      _$TipModelFromJson(json);

  Map<String, dynamic> toJson() => _$TipModelToJson(this);
}
