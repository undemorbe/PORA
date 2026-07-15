// import 'package:pora/app/features/auth/data/datasources/remote.dart';
// import 'package:pora/app/features/auth/domain/entity/auth_types.dart';
// import 'package:pora/app/internal/errors/failure.dart';
// import 'package:pora/app/internal/errors/success.dart';
// import 'package:pora/app/internal/extensions/either.dart';

// class GetOtp {
//   const GetOtp({required this.authType, required this.networkOtp});

//   final AuthTypes authType;
//   final NetworkOtp networkOtp;

//   Future<Either<Failure, Success>> callGettingOtp({
//     required AuthTypes authType,
//     required String login,
//   }) async {
//     return Right(
//       ServerSuccess('200', networkOtp.getOtp(authType: authType, login: login)),
//     );
//   }
// }
