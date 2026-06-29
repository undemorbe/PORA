
import 'package:pora/app/internal/network/network_abstract.dart';

class RefreshTokensRequest {
  
  RefreshTokensRequest({
    required this.networkFetcher,
    required this.refreshToken,
  });
  
  final INetworkService networkFetcher;
  final String refreshToken;

  Future<Map<String, dynamic>> fetchAccess() async {
    return await networkFetcher.get('/auth/refresh',  params:  {'refreshToken': refreshToken});
  }
}