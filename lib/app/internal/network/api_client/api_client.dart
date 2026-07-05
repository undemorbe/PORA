import 'package:dio/dio.dart';
import 'package:pora/app/features/auth_and_validation/data/models/jwt_models/tokens_model.dart';
import 'package:pora/app/features/families/data/models/family_model.dart';
import 'package:pora/app/features/families/data/models/link_code_model.dart';
import 'package:pora/app/features/user/data/models/user/user_model.dart';
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
  Future<void> checkUser({@Query('phone') required String destination});

  @POST('/authorize/send-otp')
  Future<void> sendOtp({@Body() required Map<String, dynamic> destination});

  @POST('/authorize/verify-otp')
  Future<TokensModel> verifyOtp({@Body() required Map<String, dynamic> body});

  @POST('/authorize/logout')
  Future<void> logout();

  //! User
  @POST('/user/update')
  Future<void> updateUser({@Body() required UserModel userData});

  @GET('/user/me')
  Future<UserModel> getUser();

  //! Families
  @POST('/families/create-family')
  Future<String> createFamile({
    @Body() required Map<String, dynamic> nameOfFamilyBody,
  });

  @GET('/families/get-families')
  Future<List<FamilyModel>> getFamilies();

  @POST('/families/link_code')
  Future<LinkCodeModel> getLinkCodeOfConcreteFamily({
    @Query('fid') required String familyId,
  });

  //! WAIT FOR JOIN TO BE CREATED!!!!!!!!
}
