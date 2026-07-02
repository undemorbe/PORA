import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/app/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class UpdateUser {
  const UpdateUser(this.repository);
  final UserRepository repository;
  Future<Either<Failure, UserEntity>> call(UserEntity user) =>
      repository.updateUser(user);
}
