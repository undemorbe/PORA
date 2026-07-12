import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
part 'member_model.g.dart';

@JsonSerializable()
class MemberModel extends MemberEntity {
  const MemberModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.joinedAt,
    required super.colorCode,
    super.surname,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);
  Map<String, dynamic> toJson() => _$MemberModelToJson(this);
}
