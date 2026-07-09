import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/app/features/user/domain/usecase/user/update_user.dart';
part 'user_profile_store.g.dart';

class UserProfileStore = _UserProfileStoreBase with _$UserProfileStore;

abstract class _UserProfileStoreBase with Store {
  final ImagePicker _picker = ImagePicker();

  @observable
  UserEntity? user;

  @observable
  File? profileImage;

  @action
  Future<void> pushUserInformation({required String name}) async {
    final nameToEntity = name.split(' ').first.isEmpty
        ? 'PORA-USER${DateTime.now().millisecondsSinceEpoch}'
        : name.split(' ').first;
    final surname = name.split(' ').length > 1
        ? name.split(' ').sublist(1).join(' ')
        : 'PITBULL';
    user = UserEntity(name: nameToEntity, surname: surname);
    await GetIt.I<UpdateUserUseCase>()(user: user, image: profileImage);
  }

  @action
  UserEntity? getUserFromInternet() {
    return user;
  }

  @action
  Future<void> setProfileImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage = File(image.path);
    }
  }
}
