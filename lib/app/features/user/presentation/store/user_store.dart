import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
part 'user_store.g.dart';

class UserProfileStore = _UserProfileStoreBase with _$UserProfileStore;

abstract class _UserProfileStoreBase with Store {
  @observable
  UserEntity? user;

  @observable
  File? profileImage;

  @readonly
  TextEditingController nameEditingController = TextEditingController();

  @readonly
  final picker = ImagePicker();



  @action
  void setUserInformation({String? name, String? surname, String? image}) {}

  @action
  UserEntity? getUserFromInternet() {
    return user;
  }

  @action
  void setProfileImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      profileImage = File(image.path);
    }
  }

  @action
  void dispose(){
    nameEditingController.dispose();
  }
}
