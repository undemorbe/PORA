// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brief_product_model_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BriefProductModelList _$BriefProductModelListFromJson(
  Map<String, dynamic> json,
) => BriefProductModelList(
  items: (json['brief-items'] as List<dynamic>)
      .map((e) => BriefProductModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BriefProductModelListToJson(
  BriefProductModelList instance,
) => <String, dynamic>{'brief-items': instance.items};
