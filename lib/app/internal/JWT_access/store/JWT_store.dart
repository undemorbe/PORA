import 'package:mobx/mobx.dart';
import 'package:pora/app/internal/JWT_access/data/jwt_api.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
part 'JWT_store.g.dart';

class JWTAccessStore = _JWTAccessStoreBase with _$JWTAccessStore;

abstract class _JWTAccessStoreBase with Store {
  
  final IRefreshTokensRequest refreshTokensRequest;
  final ILocalDB localDB;

  _JWTAccessStoreBase({required this.refreshTokensRequest, required this.localDB});

  @readonly
  String? accessToken;
  
  @readonly
  String? refreshToken;

  @action
  void setAccessToken(String? token) {
    accessToken = token;
  }

  @action
  void setRefreshToken(String? token) {
    refreshToken = token;
  }

  @action
  Future<void> fetchAccessToken() async {
    final result = await localDB.get(key: 'refreshToken', baseName: LocalDBNames.auth.name);
    refreshToken = result as String?;

    if (refreshToken != null) {
        final tokens = await refreshTokensRequest.fetchAccess(refreshToken: refreshToken);
        
        setAccessToken(tokens['accessToken'] as String?);
        setRefreshToken(tokens['refreshToken'] as String?);

        await localDB.set(key: 'refreshToken', value: refreshToken, baseName: LocalDBNames.auth.name);
    }
    setAccessToken(null);
    setRefreshToken(null);
  }

  @action
  void clearAccessToken() {
    accessToken = null;
  }

}