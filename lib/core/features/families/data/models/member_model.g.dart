// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => MemberModel(
  id: json['id'] as String,
  name: json['name'] as String,
  imageUrl: json['image-url'] as String?,
  joinedAt: json['joined-at'] as String,
  colorCode: json['color'] as String,
  surname: json['surname'] as String?,
);

Map<String, dynamic> _$MemberModelToJson(MemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'image-url': instance.imageUrl,
      'joined-at': instance.joinedAt,
      'color': instance.colorCode,
    };
