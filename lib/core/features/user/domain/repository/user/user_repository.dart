import 'dart:io';

import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUser();
  Future<Either<Failure, Success>> logout();

  /// Безвозвратно удаляет аккаунт на сервере.
  Future<Either<Failure, Success>> deleteAccount();
  Future<Either<Failure, Success>> updateUser({UserEntity? user, File? image});

  /// Регистрация FCM/APNS токена. Оба поля обязательны.
  Future<Either<Failure, Success>> updateDeviceToken({
    required String deviceToken,
    required String deviceType,
  });
}
