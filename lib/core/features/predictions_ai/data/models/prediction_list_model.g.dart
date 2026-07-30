// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionListModel _$PredictionListModelFromJson(Map<String, dynamic> json) =>
    PredictionListModel(
      predictionsList: (json['predictionsList'] as List<dynamic>)
          .map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PredictionListModelToJson(
  PredictionListModel instance,
) => <String, dynamic>{'predictionsList': instance.predictionsList};
