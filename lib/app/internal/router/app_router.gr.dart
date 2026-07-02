// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i18;
import 'package:flutter/material.dart' as _i19;
import 'package:pora/app/features/add_item/presentation/screen/add_item_screen.dart'
    as _i1;
import 'package:pora/app/features/auth/presentation/screen/auth.dart' as _i2;
import 'package:pora/app/features/auth/presentation/screen/confirm_code.dart'
    as _i4;
import 'package:pora/app/features/auth/presentation/screen/phone/auth_with_phone.dart'
    as _i3;
import 'package:pora/app/features/home/presentation/screen/home_screen.dart'
    as _i5;
import 'package:pora/app/features/household/presentation/screen/household_screen.dart'
    as _i6;
import 'package:pora/app/features/insights/presentation/screen/insights_screen.dart'
    as _i7;
import 'package:pora/app/features/item_detail/presentation/screen/item_detail_screen.dart'
    as _i8;
import 'package:pora/app/features/notifications/presentation/screen/notifications_screen.dart'
    as _i9;
import 'package:pora/app/features/onboarding/presentation/screen/onboarding_brief_screen.dart'
    as _i10;
import 'package:pora/app/features/onboarding/presentation/screen/onboarding_slider_screen.dart'
    as _i11;
import 'package:pora/app/features/order/presentation/screen/order_screen.dart'
    as _i12;
import 'package:pora/app/features/predictions/presentation/screen/predictions_screen.dart'
    as _i13;
import 'package:pora/app/features/recipe/presentation/screen/recipe_import_screen.dart'
    as _i14;
import 'package:pora/app/features/search/presentation/screen/search_screen.dart'
    as _i15;
import 'package:pora/app/features/settings/presentation/screen/settings_screen.dart'
    as _i16;
import 'package:pora/app/features/splash/presentation/screen/splash.dart'
    as _i17;

/// generated route for
/// [_i1.AddItemPage]
class AddItemRoute extends _i18.PageRouteInfo<void> {
  const AddItemRoute({List<_i18.PageRouteInfo>? children})
    : super(AddItemRoute.name, initialChildren: children);

  static const String name = 'AddItemRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddItemPage();
    },
  );
}

/// generated route for
/// [_i2.AuthPage]
class AuthRoute extends _i18.PageRouteInfo<void> {
  const AuthRoute({List<_i18.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthPage();
    },
  );
}

/// generated route for
/// [_i3.AuthWithPhone]
class AuthWithPhone extends _i18.PageRouteInfo<void> {
  const AuthWithPhone({List<_i18.PageRouteInfo>? children})
    : super(AuthWithPhone.name, initialChildren: children);

  static const String name = 'AuthWithPhone';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthWithPhone();
    },
  );
}

/// generated route for
/// [_i4.ConfirmCode]
class CodeConfirmer extends _i18.PageRouteInfo<CodeConfirmerArgs> {
  CodeConfirmer({
    _i19.Key? key,
    required int lengthOfPin,
    List<_i18.PageRouteInfo>? children,
  }) : super(
         CodeConfirmer.name,
         args: CodeConfirmerArgs(key: key, lengthOfPin: lengthOfPin),
         initialChildren: children,
       );

  static const String name = 'CodeConfirmer';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CodeConfirmerArgs>();
      return _i4.ConfirmCode(key: args.key, lengthOfPin: args.lengthOfPin);
    },
  );
}

class CodeConfirmerArgs {
  const CodeConfirmerArgs({this.key, required this.lengthOfPin});

  final _i19.Key? key;

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
/// [_i5.HomePage]
class HomeRoute extends _i18.PageRouteInfo<void> {
  const HomeRoute({List<_i18.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomePage();
    },
  );
}

/// generated route for
/// [_i6.HouseholdPage]
class HouseholdRoute extends _i18.PageRouteInfo<void> {
  const HouseholdRoute({List<_i18.PageRouteInfo>? children})
    : super(HouseholdRoute.name, initialChildren: children);

  static const String name = 'HouseholdRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i6.HouseholdPage();
    },
  );
}

/// generated route for
/// [_i7.InsightsPage]
class InsightsRoute extends _i18.PageRouteInfo<void> {
  const InsightsRoute({List<_i18.PageRouteInfo>? children})
    : super(InsightsRoute.name, initialChildren: children);

  static const String name = 'InsightsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i7.InsightsPage();
    },
  );
}

/// generated route for
/// [_i8.ItemDetailPage]
class ItemDetailRoute extends _i18.PageRouteInfo<void> {
  const ItemDetailRoute({List<_i18.PageRouteInfo>? children})
    : super(ItemDetailRoute.name, initialChildren: children);

  static const String name = 'ItemDetailRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i8.ItemDetailPage();
    },
  );
}

/// generated route for
/// [_i9.NotificationsPage]
class NotificationsRoute extends _i18.PageRouteInfo<void> {
  const NotificationsRoute({List<_i18.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i9.NotificationsPage();
    },
  );
}

/// generated route for
/// [_i10.OnboardingBriefPage]
class OnboardingBriefRoute extends _i18.PageRouteInfo<void> {
  const OnboardingBriefRoute({List<_i18.PageRouteInfo>? children})
    : super(OnboardingBriefRoute.name, initialChildren: children);

  static const String name = 'OnboardingBriefRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i10.OnboardingBriefPage();
    },
  );
}

/// generated route for
/// [_i11.OnboardingSliderPage]
class OnboardingSliderRoute extends _i18.PageRouteInfo<void> {
  const OnboardingSliderRoute({List<_i18.PageRouteInfo>? children})
    : super(OnboardingSliderRoute.name, initialChildren: children);

  static const String name = 'OnboardingSliderRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i11.OnboardingSliderPage();
    },
  );
}

/// generated route for
/// [_i12.OrderPage]
class OrderRoute extends _i18.PageRouteInfo<void> {
  const OrderRoute({List<_i18.PageRouteInfo>? children})
    : super(OrderRoute.name, initialChildren: children);

  static const String name = 'OrderRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i12.OrderPage();
    },
  );
}

/// generated route for
/// [_i13.PredictionsPage]
class PredictionsRoute extends _i18.PageRouteInfo<void> {
  const PredictionsRoute({List<_i18.PageRouteInfo>? children})
    : super(PredictionsRoute.name, initialChildren: children);

  static const String name = 'PredictionsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i13.PredictionsPage();
    },
  );
}

/// generated route for
/// [_i14.RecipeImportPage]
class RecipeImportRoute extends _i18.PageRouteInfo<void> {
  const RecipeImportRoute({List<_i18.PageRouteInfo>? children})
    : super(RecipeImportRoute.name, initialChildren: children);

  static const String name = 'RecipeImportRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i14.RecipeImportPage();
    },
  );
}

/// generated route for
/// [_i15.SearchPage]
class SearchRoute extends _i18.PageRouteInfo<void> {
  const SearchRoute({List<_i18.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i15.SearchPage();
    },
  );
}

/// generated route for
/// [_i16.SettingsPage]
class SettingsRoute extends _i18.PageRouteInfo<void> {
  const SettingsRoute({List<_i18.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i16.SettingsPage();
    },
  );
}

/// generated route for
/// [_i17.SplashPage]
class SplashRoute extends _i18.PageRouteInfo<void> {
  const SplashRoute({List<_i18.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i17.SplashPage();
    },
  );
}
