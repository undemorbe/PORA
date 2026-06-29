// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JWT_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$JWTAccessStore on _JWTAccessStoreBase, Store {
  late final _$accessTokenAtom = Atom(
    name: '_JWTAccessStoreBase.accessToken',
    context: context,
  );

  @override
  String? get accessToken {
    _$accessTokenAtom.reportRead();
    return super.accessToken;
  }

  @override
  set accessToken(String? value) {
    _$accessTokenAtom.reportWrite(value, super.accessToken, () {
      super.accessToken = value;
    });
  }

  late final _$refreshTokenAtom = Atom(
    name: '_JWTAccessStoreBase.refreshToken',
    context: context,
  );

  @override
  String? get refreshToken {
    _$refreshTokenAtom.reportRead();
    return super.refreshToken;
  }

  @override
  set refreshToken(String? value) {
    _$refreshTokenAtom.reportWrite(value, super.refreshToken, () {
      super.refreshToken = value;
    });
  }

  late final _$fetchAccessTokenAsyncAction = AsyncAction(
    '_JWTAccessStoreBase.fetchAccessToken',
    context: context,
  );

  @override
  Future<void> fetchAccessToken() {
    return _$fetchAccessTokenAsyncAction.run(() => super.fetchAccessToken());
  }

  late final _$_JWTAccessStoreBaseActionController = ActionController(
    name: '_JWTAccessStoreBase',
    context: context,
  );

  @override
  void setAccessToken(String? token) {
    final _$actionInfo = _$_JWTAccessStoreBaseActionController.startAction(
      name: '_JWTAccessStoreBase.setAccessToken',
    );
    try {
      return super.setAccessToken(token);
    } finally {
      _$_JWTAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRefreshToken(String? token) {
    final _$actionInfo = _$_JWTAccessStoreBaseActionController.startAction(
      name: '_JWTAccessStoreBase.setRefreshToken',
    );
    try {
      return super.setRefreshToken(token);
    } finally {
      _$_JWTAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAccessToken() {
    final _$actionInfo = _$_JWTAccessStoreBaseActionController.startAction(
      name: '_JWTAccessStoreBase.clearAccessToken',
    );
    try {
      return super.clearAccessToken();
    } finally {
      _$_JWTAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
accessToken: ${accessToken},
refreshToken: ${refreshToken}
    ''';
  }
}
