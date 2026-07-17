// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyModel _$FamilyModelFromJson(Map<String, dynamic> json) => FamilyModel(
  id: json['id'] as String,
  name: json['name'] as String,
  members: (json['members'] as List<dynamic>?)
      ?.map(
        (e) =>
            e == null ? null : MemberModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  owner: MemberModel.fromJson(json['owner'] as Map<String, dynamic>),
  createdAt: json['created-at'] as String,
  isCurrent: json['isCurrent'] as bool?,
);

Map<String, dynamic> _$FamilyModelToJson(FamilyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isCurrent': instance.isCurrent,
      'created-at': instance.createdAt,
      'members': instance.members,
      'owner': instance.owner,
    };
