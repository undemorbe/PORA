import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase({required this.repository});
  final UserRepository repository;
  Future<Either<Failure, Success>> call() async {
    return await repository.deleteAccount();
  }
}
