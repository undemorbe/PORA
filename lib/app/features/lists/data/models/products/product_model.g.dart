// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  name: json['name'] as String,
  id: json['id'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unit: json['unit'] as String,
  priority: (json['priority'] as num).toInt(),
  urgent: json['urgent'] as bool,
  checked: json['checked'] as bool,
  remindEveryDay: json['remind-every-day'] as bool?,
  addedBy: const MemberConverter().fromJson(
    json['added-by'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'priority': instance.priority,
      'urgent': instance.urgent,
      'checked': instance.checked,
      'remind-every-day': instance.remindEveryDay,
      'added-by': const MemberConverter().toJson(instance.addedBy),
    };
