// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStoreBase, Store {
  Computed<String?>? _$profileImageUrlComputed;

  @override
  String? get profileImageUrl =>
      (_$profileImageUrlComputed ??= Computed<String?>(
        () => super.profileImageUrl,
        name: '_SettingsStoreBase.profileImageUrl',
      )).value;

  late final _$userAtom = Atom(
    name: '_SettingsStoreBase.user',
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

  late final _$profileImageFileAtom = Atom(
    name: '_SettingsStoreBase.profileImageFile',
    context: context,
  );

  @override
  File? get profileImageFile {
    _$profileImageFileAtom.reportRead();
    return super.profileImageFile;
  }

  @override
  set profileImageFile(File? value) {
    _$profileImageFileAtom.reportWrite(value, super.profileImageFile, () {
      super.profileImageFile = value;
    });
  }

  late final _$setProfileImageAsyncAction = AsyncAction(
    '_SettingsStoreBase.setProfileImage',
    context: context,
  );

  @override
  Future<void> setProfileImage() {
    return _$setProfileImageAsyncAction.run(() => super.setProfileImage());
  }

  late final _$getUserMeAsyncAction = AsyncAction(
    '_SettingsStoreBase.getUserMe',
    context: context,
  );

  @override
  Future<void> getUserMe() {
    return _$getUserMeAsyncAction.run(() => super.getUserMe());
  }

  late final _$logoutAsyncAction = AsyncAction(
    '_SettingsStoreBase.logout',
    context: context,
  );

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''
user: ${user},
profileImageFile: ${profileImageFile},
profileImageUrl: ${profileImageUrl}
    ''';
  }
}
