// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:pora/app/features/auth/presentation/screen/auth.dart' as _i1;
import 'package:pora/app/features/auth/presentation/screen/phone/auth_with_phone.dart'
    as _i2;
import 'package:pora/app/features/splash/presentation/screen/splash.dart'
    as _i3;

/// generated route for
/// [_i1.AuthPage]
class AuthRoute extends _i4.PageRouteInfo<void> {
  const AuthRoute({List<_i4.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.AuthPage();
    },
  );
}

/// generated route for
/// [_i2.AuthWithPhone]
class AuthWithPhone extends _i4.PageRouteInfo<void> {
  const AuthWithPhone({List<_i4.PageRouteInfo>? children})
    : super(AuthWithPhone.name, initialChildren: children);

  static const String name = 'AuthWithPhone';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthWithPhone();
    },
  );
}

/// generated route for
/// [_i3.SplashPage]
class SplashRoute extends _i4.PageRouteInfo<void> {
  const SplashRoute({List<_i4.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.SplashPage();
    },
  );
}
