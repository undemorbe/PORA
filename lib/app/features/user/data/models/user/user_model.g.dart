// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  surname: json['surname'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  imageUrl: json['image-url'] as String?,
  selfLists: (json['lists'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'surname': instance.surname,
  'phone': instance.phone,
  'email': instance.email,
  'image-url': instance.imageUrl,
  'lists': instance.selfLists,
};
