import 'package:pora/app/features/auth/data/datasources/remote.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class ConfirmOtp {

  final NetworkOtp networkOtp;

  const ConfirmOtp({required this.networkOtp});

  Future<Either<Failure, Success>> callConfirmOtp({required String code}) async {
    final data = await networkOtp.verifyOtp(code: code);
    //! Code handle

    return Right(ServerSuccess('200', data));
  }

}

