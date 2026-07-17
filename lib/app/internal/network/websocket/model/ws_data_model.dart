import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'ws_data_model.g.dart';

@JsonSerializable()
class WsDataModel extends Equatable {
  @JsonKey(name: 'family-id')
  final String? fid;

  @JsonKey(name: 'list-id')
  final String? lid;
  @JsonKey(name: 'item-id')
  final String? iid;

  const WsDataModel(this.fid, this.lid, this.iid);

  @override
  List<Object?> get props => [fid, lid, iid];

  factory WsDataModel.fromJson(Map<String, dynamic> json) =>
      _$WsDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$WsDataModelToJson(this);
}
