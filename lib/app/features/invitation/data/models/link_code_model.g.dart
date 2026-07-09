// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkCodeModel _$LinkCodeModelFromJson(Map<String, dynamic> json) =>
    LinkCodeModel(
      linkCode: json['linkCode'] as String,
      linkUrl: json['linkUrl'] as String,
    );

Map<String, dynamic> _$LinkCodeModelToJson(LinkCodeModel instance) =>
    <String, dynamic>{
      'linkCode': instance.linkCode,
      'linkUrl': instance.linkUrl,
    };

const _$LinkCodeModelJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'linkCode': {'type': 'string'},
    'linkUrl': {'type': 'string'},
  },
  'required': ['linkCode', 'linkUrl'],
};
