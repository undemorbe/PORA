import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/predictions_ai/data/models/prediction_model.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/prediction_list.dart';
part 'prediction_list_model.g.dart';

@JsonSerializable()
class PredictionListModel extends PredictionListEntity {
  final List<PredictionModel> predictionsList;
  const PredictionListModel({required this.predictionsList})
    : super(predictions: predictionsList);

  factory PredictionListModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionListModelFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionListModelToJson(this);
}
