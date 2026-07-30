// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionModel _$PredictionModelFromJson(Map<String, dynamic> json) =>
    PredictionModel(
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      meta: json['meta'] as String,
    );

Map<String, dynamic> _$PredictionModelToJson(PredictionModel instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'name': instance.name,
      'meta': instance.meta,
    };
