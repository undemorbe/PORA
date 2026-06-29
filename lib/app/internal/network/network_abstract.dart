abstract class INetworkService {
  Future<dynamic> get(String url, {Map<String, dynamic>? params});
  Future<dynamic> post(String url, {Map<String, dynamic>? data});
  Future<dynamic> put(String url, {Map<String, dynamic>? data});
  Future<dynamic> delete(String url, {Map<String, dynamic>? data});
}
class DioNetworkService implements INetworkService {
   
  @override
  Future<dynamic> get(String url, {Map<String, dynamic>? params}) {
    // TODO: implement get
    throw UnimplementedError();
  }
  
  @override
  Future<dynamic> post(String url, {Map<String, dynamic>? data}) {
    // TODO: implement post
    throw UnimplementedError();
  }
  
  @override
  Future<dynamic> put(String url, {Map<String, dynamic>? data}) {
    // TODO: implement put
    throw UnimplementedError();
  }
  
  @override
  Future<dynamic> delete(String url, {Map<String, dynamic>? data}) {
    // TODO: implement delete
    throw UnimplementedError();
  }
  
}
