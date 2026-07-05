// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyModel _$FamilyModelFromJson(Map<String, dynamic> json) => FamilyModel(
  id: json['id'] as String,
  name: json['name'] as String,
  membersModels: (json['members'] as List<dynamic>)
      .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  ownerModel: MemberModel.fromJson(json['owner'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String,
  isCurrent: json['isCurrent'] as bool,
);

Map<String, dynamic> _$FamilyModelToJson(FamilyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt,
      'isCurrent': instance.isCurrent,
      'members': instance.membersModels.map((e) => e.toJson()).toList(),
      'owner': instance.ownerModel.toJson(),
    };
