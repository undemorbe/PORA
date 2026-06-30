import 'package:mobx/mobx.dart';
import 'package:pora/app/internal/JWT_access/datasource/JWT_api.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
part 'JWT_store.g.dart';

class JWTAccessStore = _JWTAccessStoreBase with _$JWTAccessStore;

abstract class _JWTAccessStoreBase with Store {
  
  final IRefreshTokensRequest refreshTokensRequest;
  final ILocalDB localDB;

  _JWTAccessStoreBase({required this.refreshTokensRequest, required this.localDB});

  @computed
  bool get isUser => _accessToken != null  && _refreshToken != null;

  @readonly
  String? _accessToken;
  
  @readonly
  String? _refreshToken;

  @action
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  @action
  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  @action
  Future<void> fetchAccessToken() async {
    final result = await localDB.get(key: 'refreshToken', baseName: LocalDBNames.auth.name);
    _refreshToken = result as String?;

    if (_refreshToken != null) {
        final tokens = await refreshTokensRequest.fetchAccess(refreshToken: _refreshToken);
        
        setAccessToken(tokens['accessToken'] as String?);
        setRefreshToken(tokens['refreshToken'] as String?);

        await localDB.set(key: 'refreshToken', value: _refreshToken, baseName: LocalDBNames.auth.name);
    }
    setAccessToken(null);
    setRefreshToken(null);
  }

  @action
  void clearAccessToken() {
    _accessToken = null;
  }

}