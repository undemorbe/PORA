import 'package:pora/core/features/groups/domain/entity/user_groups.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class GroupsRepository {
  /// Все семьи (со списками) + личные списки одним запросом.
  Future<Either<Failure, UserGroupsEntity>> getUserGroups();
}
