import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/features/groups/domain/repository/groups_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetUserGroupsUseCase {
  final GroupsRepository groupsRepository;

  const GetUserGroupsUseCase({required this.groupsRepository});

  Future<Either<Failure, UserGroupsEntity>> call() =>
      groupsRepository.getUserGroups();
}
