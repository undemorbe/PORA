import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/features/user/domain/usecase/user/update_user.dart';
import 'package:pora/core/internal/formatters/image_formatter.dart';
import 'package:pora/core/internal/logging/logger.dart';
part 'user_profile_store.g.dart';

class UserProfileStore = _UserProfileStoreBase with _$UserProfileStore;

abstract class _UserProfileStoreBase with Store {
  @observable
  UserEntity? user;

  @observable
  File? profileImage;

  @observable
  bool? isLoadingImage;

  @action
  Future<void> pushUserInformation({required String name}) async {
    final nameToEntity = name.split(' ').first.isEmpty
        ? 'User${DateTime.now().millisecondsSinceEpoch}'
        : name.split(' ').first;
    final surname = name.split(' ').length > 1
        ? name.split(' ').sublist(1).join(' ')
        : '';
    user = UserEntity(name: nameToEntity, surname: surname);
    await GetIt.I<UpdateUserUseCase>()(user: user, image: profileImage);
    //! Add local saving of user-info
  }

  @action
  UserEntity? getUserFromInternet() {
    return user;
  }

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
        profileImage = processedImage;
        await GetIt.I<UpdateUserUseCase>().call(
          image: File(processedImage.path),
        );
        isLoadingImage = false;
      }
    } catch (e) {
      Logger.talker.error("Error processing image: $e");
    } finally {
      isLoadingImage = false;
    }
  }
}
