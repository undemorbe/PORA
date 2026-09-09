import 'dart:io';

import 'package:pora/core/features/user/data/datasource/remote.dart';
import 'package:pora/core/features/user/data/models/user/user_model.dart';
import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/cache/offline_policy.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

const _profileCacheKey = 'profile:user-me-v1';

class UserService implements UserRepository {
  const UserService(this.remoteDataSource);
  final UserRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    try {
      final model = await remoteDataSource.getUser();
      await HiveJsonCache.put(_profileCacheKey, model.toJson());
      return Right(model.toEntity());
    } catch (e, s) {
      return _cachedUserOr(FailureMapper.map(e, s));
    }
  }

  /// Кэш профиля отдаём только при проблемах с доступностью — при 4xx
  /// возвращаем честную ошибку.
  Future<Either<Failure, UserEntity>> _cachedUserOr(Failure failure) async {
    if (canServeCache(failure)) {
      final raw = await HiveJsonCache.read(_profileCacheKey);
      if (raw is Map) {
        try {
          return Right(
            UserModel.fromJson(Map<String, dynamic>.from(raw)).toEntity(),
          );
        } catch (_) {
          // Broken cache is treated as a cache miss.
        }
      }
    }
    return Left(failure);
  }

  @override
  Future<Either<Failure, Success>> updateUser({
    UserEntity? user,
    File? image,
  }) async {
    try {
      await remoteDataSource.updateUser(
        user != null ? UserModel.fromEntity(user) : null,
        image,
      );
      return Right(const ServerSuccess());
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, Success>> updateDeviceToken({
    required String deviceToken,
    required String deviceType,
  }) async {
    try {
      await remoteDataSource.updateDevice(
        deviceToken: deviceToken,
        deviceType: deviceType,
      );
      return Right(const ServerSuccess());
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, Success>> logout() async {
    try {
      await remoteDataSource.logout();
      return Right(const ServerSuccess());
    } catch (e, s) {
      return Left(FailureMapper.map(e, s));
    }
  }
}
