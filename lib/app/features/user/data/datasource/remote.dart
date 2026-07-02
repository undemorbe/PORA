import 'package:pora/app/features/user/data/models/user/user_model.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser();
  Future<void> updateUser(UserModel model);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<UserModel> getUser() => apiClient.getUser();

  @override
  Future<void> updateUser(UserModel model) =>
      apiClient.updateUser(userData: model);
}
