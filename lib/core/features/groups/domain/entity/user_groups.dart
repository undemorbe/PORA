import 'package:equatable/equatable.dart';
import 'package:pora/core/features/groups/domain/entity/group.dart';

/// Результат `GET /user/groups`: все списки семей пользователя и его личные
/// списки, уже развёрнутые в плоский список [GroupEntity] (сначала семейные).
class UserGroupsEntity extends Equatable {
  final List<GroupEntity> groups;

  const UserGroupsEntity({required this.groups});

  @override
  List<Object?> get props => [groups];
}
