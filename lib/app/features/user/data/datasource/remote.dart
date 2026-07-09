import 'dart:io';

import 'package:pora/app/features/user/data/models/user/user_model.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser();
  Future<void> updateUser(UserModel? model, File? image);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<UserModel> getUser() => apiClient.getUser();

  @override
  Future<void> updateUser(UserModel? model, File? image) async {
    if (model != null) {
      await apiClient.updateUser(userData: model.toUpdateModel());
    }
    if (image != null) {
      await apiClient.saveUserImage(file: image);
    }
  }
}
