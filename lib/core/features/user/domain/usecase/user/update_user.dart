import 'dart:io';

import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class UpdateUserUseCase {
  const UpdateUserUseCase(this.repository);
  final UserRepository repository;
  Future<Either<Failure, Success>> call({UserEntity? user, File? image}) async {
    return await repository.updateUser(user: user, image: image);
  }
}
