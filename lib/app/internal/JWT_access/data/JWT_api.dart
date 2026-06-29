import 'package:pora/app/internal/network/network_abstract.dart';

abstract class IRefreshTokensRequest{
  Future<Map<String, dynamic>> fetchAccess({String? refreshToken});
}

class RefreshTokensRequest implements IRefreshTokensRequest {
  
  RefreshTokensRequest({
    required this.networkService,
  });
  
  final INetworkService networkService;

  @override
  Future<Map<String, dynamic>> fetchAccess({String? refreshToken}) async {
    return await networkService.get('/auth/refresh',  params:  {'refreshToken': refreshToken});
  }
}