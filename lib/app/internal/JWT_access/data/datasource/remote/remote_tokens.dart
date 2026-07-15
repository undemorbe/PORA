import 'package:pora/app/internal/JWT_access/domain/entity/tokens_entity.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

abstract class TokensRemoteDataSource {
  Future<TokensEntity> refreshTokens({required String? refreshToken});
}

class TokensRemoteDataSourceImpl implements TokensRemoteDataSource {
  const TokensRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<TokensEntity> refreshTokens({required String? refreshToken}) =>
      apiClient.refreshTokens(refreshToken: refreshToken ?? '');
}
