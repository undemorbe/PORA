import 'package:dio/dio.dart';
import 'package:pora/app/features/user/data/models/user/user_model.dart';
import 'package:pora/app/internal/JWT_access/data/models/tokens_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'api_client.g.dart';

/// Единый HTTP-контракт (Retrofit). Возвращает DTO/void — без Either/Failure
/// (перевод ошибок в репозиториях). Authorization подставляет AuthInterceptor.
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  //! Authorization
  @GET('/authorize/refresh')
  Future<TokensModel> refreshTokens({
    @Query('refresh-token') required String refreshToken,
  });

  @GET('/authorize/check-user')
  Future<void> checkUser({@Query('phone') required String phone});

  @POST('/authorize/send-otp')
  Future<void> sendOtp({@Body() required Map<String, String> body});

  @POST('/authorize/verify-otp')
  Future<void> verifyOtp({@Body() required Map<String, String> body});

  @POST('/authorize/logout')
  Future<void> logout();

  //! User
  @POST('/user/update')
  Future<void> updateUser({@Body() required UserModel userData});

  @GET('/user/me')
  Future<UserModel> getUser();
}
