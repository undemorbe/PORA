// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingListModel _$ShoppingListModelFromJson(Map<String, dynamic> json) =>
    ShoppingListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      highPriorityProductsModels:
          (json['highPriorityProducts'] as List<dynamic>)
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ShoppingListModelToJson(ShoppingListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'highPriorityProducts': instance.highPriorityProductsModels
          .map((e) => e.toJson())
          .toList(),
    };
