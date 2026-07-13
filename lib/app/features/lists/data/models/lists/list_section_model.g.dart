// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListSectionModel _$ListSectionModelFromJson(Map<String, dynamic> json) =>
    ListSectionModel(
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => const ProductConverter().fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      id: json['id'] as String,
    );

Map<String, dynamic> _$ListSectionModelToJson(ListSectionModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'items': instance.items.map(const ProductConverter().toJson).toList(),
    };
