// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:flutter/material.dart' as _i23;
import 'package:pora/app/features/add_item/presentation/screen/add_item_screen.dart'
    as _i1;
import 'package:pora/app/features/auth_and_validation/presentation/controller/auth_store.dart'
    as _i24;
import 'package:pora/app/features/auth_and_validation/presentation/controller/privacy_store.dart'
    as _i25;
import 'package:pora/app/features/auth_and_validation/presentation/screens/auth_otp_confirm.dart'
    as _i12;
import 'package:pora/app/features/auth_and_validation/presentation/screens/auth_screen.dart'
    as _i2;
import 'package:pora/app/features/brief/presentation/screens/brief_screen.dart'
    as _i3;
import 'package:pora/app/features/families/presentation/screen/families_screen.dart'
    as _i4;
import 'package:pora/app/features/insights/presentation/screen/insights_screen.dart'
    as _i8;
import 'package:pora/app/features/invitation/presentation/screen/connection_to_other/household_connection_screen.dart'
    as _i6;
import 'package:pora/app/features/invitation/presentation/screen/household_screen.dart'
    as _i7;
import 'package:pora/app/features/item_detail/presentation/screen/item_detail_screen.dart'
    as _i9;
import 'package:pora/app/features/list/presentation/screen/home_screen.dart'
    as _i5;
import 'package:pora/app/features/notifications/presentation/screen/notifications_screen.dart'
    as _i11;
import 'package:pora/app/features/onboarding/presentation/screen/onboarding_slider_screen.dart'
    as _i13;
import 'package:pora/app/features/order/presentation/screen/order_screen.dart'
    as _i14;
import 'package:pora/app/features/predictions/presentation/screen/predictions_screen.dart'
    as _i15;
import 'package:pora/app/features/recipe/presentation/screen/recipe_import_screen.dart'
    as _i16;
import 'package:pora/app/features/search/presentation/screen/search_screen.dart'
    as _i17;
import 'package:pora/app/features/settings/presentation/screen/settings_screen.dart'
    as _i18;
import 'package:pora/app/features/shell/presentation/screen/main_shell_screen.dart'
    as _i10;
import 'package:pora/app/features/splash/presentation/screen/splash.dart'
    as _i19;
import 'package:pora/app/features/user/presentation/screens/user_create_profile_screen.dart'
    as _i20;
import 'package:pora/app/features/welcome_back/presentation/screen/welcome_back_screen.dart'
    as _i21;

/// generated route for
/// [_i1.AddItemPage]
class AddItemRoute extends _i22.PageRouteInfo<void> {
  const AddItemRoute({List<_i22.PageRouteInfo>? children})
    : super(AddItemRoute.name, initialChildren: children);

  static const String name = 'AddItemRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddItemPage();
    },
  );
}

/// generated route for
/// [_i2.AuthPage]
class AuthRoute extends _i22.PageRouteInfo<void> {
  const AuthRoute({List<_i22.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthPage();
    },
  );
}

/// generated route for
/// [_i3.BriefPage]
class BriefRoute extends _i22.PageRouteInfo<void> {
  const BriefRoute({List<_i22.PageRouteInfo>? children})
    : super(BriefRoute.name, initialChildren: children);

  static const String name = 'BriefRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i3.BriefPage();
    },
  );
}

/// generated route for
/// [_i4.FamiliesPage]
class FamiliesRoute extends _i22.PageRouteInfo<FamiliesRouteArgs> {
  FamiliesRoute({_i23.Key? key, List<_i22.PageRouteInfo>? children})
    : super(
        FamiliesRoute.name,
        args: FamiliesRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'FamiliesRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FamiliesRouteArgs>(
        orElse: () => const FamiliesRouteArgs(),
      );
      return _i4.FamiliesPage(key: args.key);
    },
  );
}

class FamiliesRouteArgs {
  const FamiliesRouteArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'FamiliesRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FamiliesRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i5.HomePage]
class HomeRoute extends _i22.PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    _i23.Key? key,
    String? familyId,
    String? familyName,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         HomeRoute.name,
         args: HomeRouteArgs(
           key: key,
           familyId: familyId,
           familyName: familyName,
         ),
         initialChildren: children,
       );

  static const String name = 'HomeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteArgs>(
        orElse: () => const HomeRouteArgs(),
      );
      return _i5.HomePage(
        key: args.key,
        familyId: args.familyId,
        familyName: args.familyName,
      );
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({this.key, this.familyId, this.familyName});

  final _i23.Key? key;

  final String? familyId;

  final String? familyName;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key, familyId: $familyId, familyName: $familyName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteArgs) return false;
    return key == other.key &&
        familyId == other.familyId &&
        familyName == other.familyName;
  }

  @override
  int get hashCode => key.hashCode ^ familyId.hashCode ^ familyName.hashCode;
}

/// generated route for
/// [_i6.HouseholdConnectionPage]
class HouseholdConnectionRoute
    extends _i22.PageRouteInfo<HouseholdConnectionRouteArgs> {
  HouseholdConnectionRoute({
    _i23.Key? key,
    required String linkCode,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         HouseholdConnectionRoute.name,
         args: HouseholdConnectionRouteArgs(key: key, linkCode: linkCode),
         rawPathParams: {'linkCode': linkCode},
         initialChildren: children,
       );

  static const String name = 'HouseholdConnectionRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<HouseholdConnectionRouteArgs>(
        orElse: () => HouseholdConnectionRouteArgs(
          linkCode: pathParams.getString('linkCode'),
        ),
      );
      return _i6.HouseholdConnectionPage(
        key: args.key,
        linkCode: args.linkCode,
      );
    },
  );
}

class HouseholdConnectionRouteArgs {
  const HouseholdConnectionRouteArgs({this.key, required this.linkCode});

  final _i23.Key? key;

  final String linkCode;

  @override
  String toString() {
    return 'HouseholdConnectionRouteArgs{key: $key, linkCode: $linkCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HouseholdConnectionRouteArgs) return false;
    return key == other.key && linkCode == other.linkCode;
  }

  @override
  int get hashCode => key.hashCode ^ linkCode.hashCode;
}

/// generated route for
/// [_i7.HouseholdPage]
class HouseholdRoute extends _i22.PageRouteInfo<HouseholdRouteArgs> {
  HouseholdRoute({
    _i23.Key? key,
    required String familyId,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         HouseholdRoute.name,
         args: HouseholdRouteArgs(key: key, familyId: familyId),
         initialChildren: children,
       );

  static const String name = 'HouseholdRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HouseholdRouteArgs>();
      return _i7.HouseholdPage(key: args.key, familyId: args.familyId);
    },
  );
}

class HouseholdRouteArgs {
  const HouseholdRouteArgs({this.key, required this.familyId});

  final _i23.Key? key;

  final String familyId;

  @override
  String toString() {
    return 'HouseholdRouteArgs{key: $key, familyId: $familyId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HouseholdRouteArgs) return false;
    return key == other.key && familyId == other.familyId;
  }

  @override
  int get hashCode => key.hashCode ^ familyId.hashCode;
}

/// generated route for
/// [_i8.InsightsPage]
class InsightsRoute extends _i22.PageRouteInfo<void> {
  const InsightsRoute({List<_i22.PageRouteInfo>? children})
    : super(InsightsRoute.name, initialChildren: children);

  static const String name = 'InsightsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i8.InsightsPage();
    },
  );
}

/// generated route for
/// [_i9.ItemDetailPage]
class ItemDetailRoute extends _i22.PageRouteInfo<void> {
  const ItemDetailRoute({List<_i22.PageRouteInfo>? children})
    : super(ItemDetailRoute.name, initialChildren: children);

  static const String name = 'ItemDetailRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i9.ItemDetailPage();
    },
  );
}

/// generated route for
/// [_i10.MainShellPage]
class MainShellRoute extends _i22.PageRouteInfo<void> {
  const MainShellRoute({List<_i22.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.MainShellPage();
    },
  );
}

/// generated route for
/// [_i11.NotificationsPage]
class NotificationsRoute extends _i22.PageRouteInfo<void> {
  const NotificationsRoute({List<_i22.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.NotificationsPage();
    },
  );
}

/// generated route for
/// [_i12.OTPConfirmationPage]
class OTPConfirmationRoute
    extends _i22.PageRouteInfo<OTPConfirmationRouteArgs> {
  OTPConfirmationRoute({
    _i23.Key? key,
    required _i24.AuthStore authStore,
    required _i23.TextEditingController OTPController,
    required bool isPhone,
    required _i23.TextEditingController destinationController,
    required _i25.PrivacyStore privacyStore,
    List<_i22.PageRouteInfo>? children,
  }) : super(
         OTPConfirmationRoute.name,
         args: OTPConfirmationRouteArgs(
           key: key,
           authStore: authStore,
           OTPController: OTPController,
           isPhone: isPhone,
           destinationController: destinationController,
           privacyStore: privacyStore,
         ),
         initialChildren: children,
       );

  static const String name = 'OTPConfirmationRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OTPConfirmationRouteArgs>();
      return _i12.OTPConfirmationPage(
        key: args.key,
        authStore: args.authStore,
        OTPController: args.OTPController,
        isPhone: args.isPhone,
        destinationController: args.destinationController,
        privacyStore: args.privacyStore,
      );
    },
  );
}

class OTPConfirmationRouteArgs {
  const OTPConfirmationRouteArgs({
    this.key,
    required this.authStore,
    required this.OTPController,
    required this.isPhone,
    required this.destinationController,
    required this.privacyStore,
  });

  final _i23.Key? key;

  final _i24.AuthStore authStore;

  final _i23.TextEditingController OTPController;

  final bool isPhone;

  final _i23.TextEditingController destinationController;

  final _i25.PrivacyStore privacyStore;

  @override
  String toString() {
    return 'OTPConfirmationRouteArgs{key: $key, authStore: $authStore, OTPController: $OTPController, isPhone: $isPhone, destinationController: $destinationController, privacyStore: $privacyStore}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OTPConfirmationRouteArgs) return false;
    return key == other.key &&
        authStore == other.authStore &&
        OTPController == other.OTPController &&
        isPhone == other.isPhone &&
        destinationController == other.destinationController &&
        privacyStore == other.privacyStore;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      authStore.hashCode ^
      OTPController.hashCode ^
      isPhone.hashCode ^
      destinationController.hashCode ^
      privacyStore.hashCode;
}

/// generated route for
/// [_i13.OnboardingSliderPage]
class OnboardingSliderRoute extends _i22.PageRouteInfo<void> {
  const OnboardingSliderRoute({List<_i22.PageRouteInfo>? children})
    : super(OnboardingSliderRoute.name, initialChildren: children);

  static const String name = 'OnboardingSliderRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i13.OnboardingSliderPage();
    },
  );
}

/// generated route for
/// [_i14.OrderPage]
class OrderRoute extends _i22.PageRouteInfo<void> {
  const OrderRoute({List<_i22.PageRouteInfo>? children})
    : super(OrderRoute.name, initialChildren: children);

  static const String name = 'OrderRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i14.OrderPage();
    },
  );
}

/// generated route for
/// [_i15.PredictionsPage]
class PredictionsRoute extends _i22.PageRouteInfo<void> {
  const PredictionsRoute({List<_i22.PageRouteInfo>? children})
    : super(PredictionsRoute.name, initialChildren: children);

  static const String name = 'PredictionsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i15.PredictionsPage();
    },
  );
}

/// generated route for
/// [_i16.RecipeImportPage]
class RecipeImportRoute extends _i22.PageRouteInfo<void> {
  const RecipeImportRoute({List<_i22.PageRouteInfo>? children})
    : super(RecipeImportRoute.name, initialChildren: children);

  static const String name = 'RecipeImportRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i16.RecipeImportPage();
    },
  );
}

/// generated route for
/// [_i17.SearchPage]
class SearchRoute extends _i22.PageRouteInfo<void> {
  const SearchRoute({List<_i22.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i17.SearchPage();
    },
  );
}

/// generated route for
/// [_i18.SettingsPage]
class SettingsRoute extends _i22.PageRouteInfo<void> {
  const SettingsRoute({List<_i22.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i18.SettingsPage();
    },
  );
}

/// generated route for
/// [_i19.SplashPage]
class SplashRoute extends _i22.PageRouteInfo<void> {
  const SplashRoute({List<_i22.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i19.SplashPage();
    },
  );
}

/// generated route for
/// [_i20.UserCreateProfilePage]
class UserCreateProfileRoute extends _i22.PageRouteInfo<void> {
  const UserCreateProfileRoute({List<_i22.PageRouteInfo>? children})
    : super(UserCreateProfileRoute.name, initialChildren: children);

  static const String name = 'UserCreateProfileRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.UserCreateProfilePage();
    },
  );
}

/// generated route for
/// [_i21.WelcomeBackPage]
class WelcomeBackRoute extends _i22.PageRouteInfo<void> {
  const WelcomeBackRoute({List<_i22.PageRouteInfo>? children})
    : super(WelcomeBackRoute.name, initialChildren: children);

  static const String name = 'WelcomeBackRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i21.WelcomeBackPage();
    },
  );
}
