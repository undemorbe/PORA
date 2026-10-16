import 'package:pora/core/features/groups/data/datasource/remote/groups_remote.dart';
import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/features/groups/domain/repository/groups_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GroupsService implements GroupsRepository {
  final GroupsRemote groupsRemote;

  const GroupsService({required this.groupsRemote});

  @override
  Future<Either<Failure, UserGroupsEntity>> getUserGroups() =>
      groupsRemote.getUserGroups();
}
