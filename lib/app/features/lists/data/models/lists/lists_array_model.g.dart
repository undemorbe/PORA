// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_array_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListsArrayModel _$ListsArrayModelFromJson(Map<String, dynamic> json) =>
    ListsArrayModel(
      lists: (json['lists'] as List<dynamic>)
          .map(
            (e) => const ListSectionConverter().fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$ListsArrayModelToJson(ListsArrayModel instance) =>
    <String, dynamic>{
      'lists': instance.lists.map(const ListSectionConverter().toJson).toList(),
    };
