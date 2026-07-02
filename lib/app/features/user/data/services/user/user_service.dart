import 'package:dio/dio.dart';
import 'package:pora/app/features/user/data/datasource/remote.dart';
import 'package:pora/app/features/user/data/models/user/user_model.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/app/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class UserService implements UserRepository {
  const UserService(this.remoteDataSource);
  final UserRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    try {
      final model = await remoteDataSource.getUser();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(const ServerFailure('Unknown error'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    try {
      await remoteDataSource.updateUser(UserModel.fromEntity(user));
      return Right(user);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(const ServerFailure('Unknown error'));
    }
  }

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure();
      default:
        return const ServerFailure('Unknown error');
    }
  }
}
