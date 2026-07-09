// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserProfileStore on _UserProfileStoreBase, Store {
  late final _$userAtom = Atom(
    name: '_UserProfileStoreBase.user',
    context: context,
  );

  @override
  UserEntity? get user {
    _$userAtom.reportRead();
    return super.user;
  }

  @override
  set user(UserEntity? value) {
    _$userAtom.reportWrite(value, super.user, () {
      super.user = value;
    });
  }

  late final _$profileImageAtom = Atom(
    name: '_UserProfileStoreBase.profileImage',
    context: context,
  );

  @override
  File? get profileImage {
    _$profileImageAtom.reportRead();
    return super.profileImage;
  }

  @override
  set profileImage(File? value) {
    _$profileImageAtom.reportWrite(value, super.profileImage, () {
      super.profileImage = value;
    });
  }

  late final _$pushUserInformationAsyncAction = AsyncAction(
    '_UserProfileStoreBase.pushUserInformation',
    context: context,
  );

  @override
  Future<void> pushUserInformation() {
    return _$pushUserInformationAsyncAction.run(
      () => super.pushUserInformation(),
    );
  }

  late final _$setProfileImageAsyncAction = AsyncAction(
    '_UserProfileStoreBase.setProfileImage',
    context: context,
  );

  @override
  Future<void> setProfileImage() {
    return _$setProfileImageAsyncAction.run(() => super.setProfileImage());
  }

  late final _$_UserProfileStoreBaseActionController = ActionController(
    name: '_UserProfileStoreBase',
    context: context,
  );

  @override
  UserEntity? getUserFromInternet() {
    final _$actionInfo = _$_UserProfileStoreBaseActionController.startAction(
      name: '_UserProfileStoreBase.getUserFromInternet',
    );
    try {
      return super.getUserFromInternet();
    } finally {
      _$_UserProfileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$_UserProfileStoreBaseActionController.startAction(
      name: '_UserProfileStoreBase.dispose',
    );
    try {
      return super.dispose();
    } finally {
      _$_UserProfileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
user: ${user},
profileImage: ${profileImage}
    ''';
  }
}
