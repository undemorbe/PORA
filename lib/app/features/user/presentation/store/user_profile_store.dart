import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/app/features/user/domain/usecase/user/update_user.dart';
part 'user_profile_store.g.dart';

class UserProfileStore = _UserProfileStoreBase with _$UserProfileStore;

abstract class _UserProfileStoreBase with Store {
  final TextEditingController nameEditingController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @observable
  UserEntity? user;

  @observable
  File? profileImage;

  @action
  Future<void> pushUserInformation() async {
    final name = nameEditingController.text.split(' ').first.isEmpty ? 'PORA-USER${DateTime.now().millisecondsSinceEpoch}' :  nameEditingController.text.split(' ').first;
    final surname = nameEditingController.text.split(' ').length > 1
        ? nameEditingController.text.split(' ').sublist(1).join(' ')
        : 'PITBULL';
    user = UserEntity(name: name, surname: surname);
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

  @action
  void dispose() {
    nameEditingController.dispose();
  }
}
