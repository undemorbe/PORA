// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokensModel _$TokensModelFromJson(Map<String, dynamic> json) => TokensModel(
  accessToken: json['access-token'] as String,
  refreshToken: json['refresh-token'] as String,
  status: json['status'] as String?,
);

Map<String, dynamic> _$TokensModelToJson(TokensModel instance) =>
    <String, dynamic>{
      'access-token': instance.accessToken,
      'refresh-token': instance.refreshToken,
      'status': instance.status,
    };

const _$TokensModelJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'access-token': {'type': 'string'},
    'refresh-token': {'type': 'string'},
    'status': {
      'type': 'string',
      'description':
          'Статус пользователя из ответа verify-otp (например, `notRegistered`).\nМожет отсутствовать (refresh-эндпоинт его не отдаёт).',
    },
  },
  'required': ['access-token', 'refresh-token'],
};
