// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WsDataModel _$WsDataModelFromJson(Map<String, dynamic> json) => WsDataModel(
  json['family-id'] as String?,
  json['list-id'] as String?,
  json['item-id'] as String?,
);

Map<String, dynamic> _$WsDataModelToJson(WsDataModel instance) =>
    <String, dynamic>{
      'family-id': instance.fid,
      'list-id': instance.lid,
      'item-id': instance.iid,
    };
