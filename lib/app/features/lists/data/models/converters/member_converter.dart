import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/data/models/member_model.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';

class MemberConverter
    implements JsonConverter<MemberEntity, Map<String, dynamic>> {
  const MemberConverter();

  @override
  MemberEntity fromJson(Map<String, dynamic> json) =>
      MemberModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(MemberEntity object) =>
      (object as MemberModel).toJson();
}
