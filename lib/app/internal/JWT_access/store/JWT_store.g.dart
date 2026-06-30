// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JWT_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$JWTAccessStore on _JWTAccessStoreBase, Store {
  Computed<bool>? _$isUserComputed;

  @override
  bool get isUser => (_$isUserComputed ??= Computed<bool>(
    () => super.isUser,
    name: '_JWTAccessStoreBase.isUser',
  )).value;

  late final _$_accessTokenAtom = Atom(
    name: '_JWTAccessStoreBase._accessToken',
    context: context,
  );

  String? get accessToken {
    _$_accessTokenAtom.reportRead();
    return super._accessToken;
  }

  @override
  String? get _accessToken => accessToken;

  @override
  set _accessToken(String? value) {
    _$_accessTokenAtom.reportWrite(value, super._accessToken, () {
      super._accessToken = value;
    });
  }

  late final _$_refreshTokenAtom = Atom(
    name: '_JWTAccessStoreBase._refreshToken',
    context: context,
  );

  String? get refreshToken {
    _$_refreshTokenAtom.reportRead();
    return super._refreshToken;
  }

  @override
  String? get _refreshToken => refreshToken;

  @override
  set _refreshToken(String? value) {
    _$_refreshTokenAtom.reportWrite(value, super._refreshToken, () {
      super._refreshToken = value;
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
isUser: ${isUser}
    ''';
  }
}
