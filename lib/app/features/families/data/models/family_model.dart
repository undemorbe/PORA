// ignore_for_file: overridden_fields
import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/data/models/member_model.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
part 'family_model.g.dart';

@JsonSerializable()
class FamilyModel extends FamilyEntity {
  const FamilyModel({
    required super.id,
    required super.name,
    required this.members,
    required this.owner,
    required super.createdAt,
    required super.isCurrent,
  }) : super(members: members, owner: owner);
  @override
  final List<MemberModel> members;
  @override
  final MemberModel owner;

  factory FamilyModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyModelFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyModelToJson(this);
}
