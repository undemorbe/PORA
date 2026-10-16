import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/network/api_client/api_client.dart';

abstract class GroupsRemote {
  Future<Either<Failure, UserGroupsEntity>> getUserGroups();
}

class GroupsRemoteImpl implements GroupsRemote {
  final ApiClient apiClient;

  const GroupsRemoteImpl({required this.apiClient});

  @override
  Future<Either<Failure, UserGroupsEntity>> getUserGroups() async {
    try {
      return Right(await apiClient.getUserGroups());
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }
}
