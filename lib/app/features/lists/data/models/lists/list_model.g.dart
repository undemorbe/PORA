// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListModel _$ListModelFromJson(Map<String, dynamic> json) => ListModel(
  id: json['id'] as String,
  name: json['name'] as String,
  sections: (json['sections'] as List<dynamic>)
      .map(
        (e) => const ListSectionConverter().fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ListModelToJson(ListModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sections': instance.sections
      .map(const ListSectionConverter().toJson)
      .toList(),
};
