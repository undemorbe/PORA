import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/prediction.dart';
part 'prediction_model.g.dart';

@JsonSerializable()
class PredictionModel extends PredictionEntity {
  const PredictionModel({
    required super.emoji,
    required super.name,
    required super.meta,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionModelFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionModelToJson(this);
}
