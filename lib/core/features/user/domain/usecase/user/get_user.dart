import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetUserUseCase {
  const GetUserUseCase(this.repository);
  final UserRepository repository;
  Future<Either<Failure, UserEntity>> call() => repository.getUser();
}
