import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pora/app/features/auth_and_validation/data/models/jwt_models/tokens_model.dart';
import 'package:pora/app/features/families/data/models/families_models.dart';
import 'package:pora/app/features/item_detail/data/models/add_item_response.dart';
import 'package:pora/app/features/invitation/data/models/link_code_model.dart';
import 'package:pora/app/features/lists/data/models/lists/list_model.dart';
import 'package:pora/app/features/lists/data/models/lists/lists_array_model.dart';
import 'package:pora/app/features/lists/data/models/products/product_model.dart';
import 'package:pora/app/features/user/data/models/user/user_model.dart';
import 'package:pora/app/features/user/data/models/user/user_update_model.dart';
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
  @PATCH('/user/update')
  Future<void> updateUser({@Body() required UserUpdateModel userData});

  @GET('/user/me')
  Future<UserModel> getUser();

  @POST('/user/save-image')
  @MultiPart()
  Future<String> saveUserImage({@Part(name: 'image') required File file});

  @PUT('/user/device')
  Future<void> updateUserDevice({
    @Body() required Map<String, dynamic> body,
  });

  //! Families
  @POST('/families/create-family')
  Future<String> createFamily({
    @Body() required Map<String, dynamic> nameOfFamilyBody,
  });

  @GET('/families')
  Future<FamiliesModels> getFamilies();

  @GET('/families/link-code')
  Future<LinkCodeModel> getLinkCodeOfConcreteFamily({
    @Query('family-id') required String familyId,
  });

  @POST('/families/join/{link_code}')
  Future<void> joinFamily({@Path('link_code') required String code});

  @GET('/families/{fid}/lists')
  Future<ListsArrayModel> getFamilyPreviewShoppingList({
    @Path('fid') required String familyId,
  });

  @DELETE('/families/{fid}')
  Future<void> deleteFamily({@Path('fid') required String familyId});

  //! Lists
  @POST('/lists/create-list')
  Future<void> createList({@Body() required Map<String, dynamic> body});

  @GET('/lists/{lid}')
  Future<ListModel> getList({@Path('lid') required String listId});

  @POST('/lists/{lid}/items')
  Future<AddItemResponse> addItem({
    @Path('lid') required String listId,
    @Body() required Map<String, dynamic> body,
  });

  @DELETE('/lists/{lid}')
  Future<void> deleteList({@Path('lid') required String listId});

  //! Items
  @GET('/items/{iid}')
  Future<ProductModel> getItem({@Path('iid') required String itemId});

  @PUT('/items/{iid}')
  Future<void> updateItem({
    @Path('iid') required String itemId,
    @Body() required Map<String, dynamic> body,
  });

  @DELETE('/items/{iid}')
  Future<void> deleteItem({@Path('iid') required String itemId});

  @POST('/items/{iid}/notify')
  Future<void> notifyAboutItem({
    @Path('iid') required String itemId,
    @Body() required Map<String, dynamic> body,
  });

  @PATCH('/items/{iid}/bought')
  Future<void> markItemBought({
    @Path('iid') required String itemId,
    @Body() required Map<String, dynamic> body,
  });
}
