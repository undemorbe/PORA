// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStoreBase, Store {
  late final _$userAtom = Atom(name: '_UserStoreBase.user', context: context);

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

  late final _$_UserStoreBaseActionController = ActionController(
    name: '_UserStoreBase',
    context: context,
  );

  @override
  void setUserInformation({String? name, String? surname, String? image}) {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
      name: '_UserStoreBase.setUserInformation',
    );
    try {
      return super.setUserInformation(
        name: name,
        surname: surname,
        image: image,
      );
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  UserEntity? getUserFromInternet() {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
      name: '_UserStoreBase.getUserFromInternet',
    );
    try {
      return super.getUserFromInternet();
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
user: ${user}
    ''';
  }
}
