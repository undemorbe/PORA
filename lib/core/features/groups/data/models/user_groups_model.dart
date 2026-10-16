import 'package:pora/core/features/families/data/models/family_model.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/features/groups/domain/entity/group.dart';
import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/features/lists/data/models/lists/list_model.dart';

/// DTO `GET /user/groups`:
/// `{families: [{...family, lists: [...]}], personal-lists: [...]}`.
class UserGroupsModel extends UserGroupsEntity {
  const UserGroupsModel({required super.groups});

  factory UserGroupsModel.fromJson(Map<String, dynamic> json) {
    final families = (json['families'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    final personal = (json['personal-lists'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();

    return UserGroupsModel(
      groups: [
        for (final raw in families) ..._familyGroups(raw),
        for (final list in personal)
          GroupEntity(list: ListModel.fromJson(list)),
      ],
    );
  }

  static List<GroupEntity> _familyGroups(Map<String, dynamic> raw) {
    final family = FamilyModel.fromJson(raw);
    final members = <MemberEntity>[
      family.owner,
      ...?family.members?.whereType<MemberEntity>(),
    ];
    return [
      for (final list
          in (raw['lists'] as List? ?? const [])
              .whereType<Map<String, dynamic>>())
        GroupEntity(
          list: ListModel.fromJson(list),
          members: members,
          ownerId: family.owner.id,
          familyId: family.id,
        ),
    ];
  }
}
