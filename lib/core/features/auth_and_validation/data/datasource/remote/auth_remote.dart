import 'package:dio/dio.dart';
import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/extensions/string_extension.dart';
import 'package:pora/core/internal/network/api_client/api_client.dart';

abstract class AuthRemote {
  Future<Either<Failure, Success>> sendOtp({required String destination});
  Future<Either<Failure, TokensEntity>> verifyOtp({
    required String destination,
    required String otp,
    required String? deviceToken,
    required String deviceType,
  });
}

class AuthRemoteImpl implements AuthRemote {
  final ApiClient apiClient;

  AuthRemoteImpl({required this.apiClient});

  @override
  Future<Either<Failure, Success>> sendOtp({
    required String destination,
  }) async {
    try {
      if (destination.isValidEmail(destination)) {
        final val = await apiClient
            .sendOtp(destination: {'email': destination})
            .then((_) {
              return const ServerSuccess();
            });
        return Right(val);
      } else if (destination.isValidPhone(destination)) {
        final val = await apiClient
            .sendOtp(destination: {'phone': destination})
            .then((_) {
              return const ServerSuccess();
            });
        return Right(val);
      }
      return Left(const NetworkFailure('Invalid destination'));

      //? Questionable, but stay for a time , ill refactor it later
    } on DioException catch (e) {
      return Left(NetworkFailure('Failed to send otp : $e'));
    }
  }

  @override
  Future<Either<Failure, TokensEntity>> verifyOtp({
    required String destination,
    required String otp,
    required String? deviceToken,
    required String deviceType,
  }) async {
    Map<String, dynamic> baseBody() => {
      'otp': otp,
      'device-token': deviceToken,
      'device-type': deviceType,
    };
    try {
      if (destination.isValidEmail(destination)) {
        final value = await apiClient.verifyOtp(
          body: {...baseBody(), 'email': destination},
        );
        return Right(value);
      } else if (destination.isValidPhone(destination)) {
        final value = await apiClient.verifyOtp(
          body: {...baseBody(), 'phone': destination},
        );
        return Right(value);
      } else {
        return Left(const ValidationFailure('Invalid destination'));
      }
    } on DioException catch (e) {
      return Left(NetworkFailure('Failed to verify otp : $e'));
    } catch (e) {
      return Left(ServerFailure('Failed to verify otp : $e'));
    }
  }
}
