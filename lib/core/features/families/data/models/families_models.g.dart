// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'families_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamiliesModels _$FamiliesModelsFromJson(Map<String, dynamic> json) =>
    FamiliesModels(
      families: (json['families'] as List<dynamic>)
          .map((e) => FamilyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FamiliesModelsToJson(FamiliesModels instance) =>
    <String, dynamic>{'families': instance.families};
