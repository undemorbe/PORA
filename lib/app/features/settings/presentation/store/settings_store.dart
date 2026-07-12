import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/app/features/user/domain/usecase/user/logout.dart';
import 'package:pora/app/internal/di/export.dart';
part 'settings_store.g.dart';

class SettingsStore = _SettingsStoreBase with _$SettingsStore;

abstract class _SettingsStoreBase with Store {
  @observable
  UserEntity? user;

  @observable
  File? profileImage;

  @action
  Future<void> setProfileImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage = File(image.path);
    }
  }

  @action
  Future<void> getUserMe() async{
    final user = await GetIt.I<GetUserUseCase>().call();
    if(user.isRight){
      this.user = user.right;
    }
  }

  @action
  Future<void> logout() async {
    await GetIt.I<LogoutUseCase>().call();
        final tokensStore = GetIt.I<TokensSecureStore>();
        await tokensStore.clearTokens();
        GetIt.I<AuthState>().setUnauthenticated();
      
      
  }
}