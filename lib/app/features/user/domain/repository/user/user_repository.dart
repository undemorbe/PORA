import 'dart:io';

import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUser();
  Future<Either<Failure, Success>> logout();
  Future<Either<Failure, Success>> updateUser({UserEntity? user, File? image});
}
