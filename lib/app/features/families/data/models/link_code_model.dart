import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/domain/entity/link_code.dart';
part 'link_code_model.g.dart';

@JsonSerializable()
class LinkCodeModel extends LinkCodeEntity {
  const LinkCodeModel({required super.linkCode, required super.linkUrl});
  
  factory LinkCodeModel.fromJson(Map<String, dynamic> json) => _$LinkCodeModelFromJson(json);
  Map<String, dynamic> toJson() => _$LinkCodeModelToJson(this);
}  