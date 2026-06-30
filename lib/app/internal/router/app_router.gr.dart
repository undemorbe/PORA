// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:pora/app/features/auth/presentation/screen/auth.dart' as _i1;
import 'package:pora/app/features/auth/presentation/screen/confirm_code.dart'
    as _i3;
import 'package:pora/app/features/auth/presentation/screen/phone/auth_with_phone.dart'
    as _i2;
import 'package:pora/app/features/splash/presentation/screen/splash.dart'
    as _i4;

/// generated route for
/// [_i1.AuthPage]
class AuthRoute extends _i5.PageRouteInfo<void> {
  const AuthRoute({List<_i5.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.AuthPage();
    },
  );
}

/// generated route for
/// [_i2.AuthWithPhone]
class AuthWithPhone extends _i5.PageRouteInfo<void> {
  const AuthWithPhone({List<_i5.PageRouteInfo>? children})
    : super(AuthWithPhone.name, initialChildren: children);

  static const String name = 'AuthWithPhone';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthWithPhone();
    },
  );
}

/// generated route for
/// [_i3.ConfirmCode]
class CodeConfirmer extends _i5.PageRouteInfo<CodeConfirmerArgs> {
  CodeConfirmer({
    _i6.Key? key,
    required int lengthOfPin,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         CodeConfirmer.name,
         args: CodeConfirmerArgs(key: key, lengthOfPin: lengthOfPin),
         initialChildren: children,
       );

  static const String name = 'CodeConfirmer';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CodeConfirmerArgs>();
      return _i3.ConfirmCode(key: args.key, lengthOfPin: args.lengthOfPin);
    },
  );
}

class CodeConfirmerArgs {
  const CodeConfirmerArgs({this.key, required this.lengthOfPin});

  final _i6.Key? key;

  final int lengthOfPin;

  @override
  String toString() {
    return 'CodeConfirmerArgs{key: $key, lengthOfPin: $lengthOfPin}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CodeConfirmerArgs) return false;
    return key == other.key && lengthOfPin == other.lengthOfPin;
  }

  @override
  int get hashCode => key.hashCode ^ lengthOfPin.hashCode;
}

/// generated route for
/// [_i4.SplashPage]
class SplashRoute extends _i5.PageRouteInfo<void> {
  const SplashRoute({List<_i5.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SplashPage();
    },
  );
}
