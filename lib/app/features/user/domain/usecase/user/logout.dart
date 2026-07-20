import 'package:pora/app/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class LogoutUseCase {
  const LogoutUseCase({required this.repository});
  final UserRepository repository;
  Future<Either<Failure, Success>> call() async {
    return await repository.logout();
  }
}
