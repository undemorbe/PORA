import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/internal/di/export.dart';
part 'settings_store.g.dart';

class SettingsStore = _SettingsStoreBase with _$SettingsStore;

abstract class _SettingsStoreBase with Store {
  @observable
  UserEntity? user;

  @computed
  String? get profileImageUrl => user?.imageUrl;

  @observable
  File? profileImageFile;

  @observable
  bool? isLoadingImage;

  @action
  Future<void> setProfileImage() async {
    final imagePicker = GetIt.I<ImagePicker>();
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    try {
      isLoadingImage = true;

      // Run the pipeline
      final File? processedImage =
          await ImageProcessingService.RepublicImageProcess(
            File(pickedFile.path),
          );

      if (processedImage != null) {
        profileImageFile = processedImage;
        await GetIt.I<UpdateUserUseCase>()
            .call(image: File(processedImage.path))
            .whenComplete(() => getUserMe());
        isLoadingImage = false;
      }
    } catch (e) {
      Logger.talker.error("Error processing image: $e");
    } finally {
      isLoadingImage = false;
    }
  }

  @action
  Future<void> getUserMe() async {
    final user = await GetIt.I<GetUserUseCase>().call();
    if (user.isRight) {
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

  @action
  Future<void> sendSupportMessage({required String text}) async {
    Logger.talker.debug('send msg $text');
  }
}
