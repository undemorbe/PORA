// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdateModel _$UserUpdateModelFromJson(Map<String, dynamic> json) =>
    UserUpdateModel(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
    );

Map<String, dynamic> _$UserUpdateModelToJson(UserUpdateModel instance) =>
    <String, dynamic>{
      'phone': ?instance.phone,
      'email': ?instance.email,
      'name': ?instance.name,
      'surname': ?instance.surname,
    };
