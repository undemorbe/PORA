// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i25;
import 'package:collection/collection.dart' as _i28;
import 'package:flutter/material.dart' as _i26;
import 'package:pora/app/features/add_item/presentation/screen/add_item_screen.dart'
    as _i1;
import 'package:pora/app/features/auth/presentation/screen/confirm_code.dart'
    as _i5;
import 'package:pora/app/features/auth/presentation/screen/phone/auth_with_phone.dart'
    as _i3;
import 'package:pora/app/features/auth_and_validation/presentation/controller/auth_store.dart'
    as _i29;
import 'package:pora/app/features/auth_and_validation/presentation/controller/privacy_store.dart'
    as _i30;
import 'package:pora/app/features/auth_and_validation/presentation/screens/auth_otp_confirm.dart'
    as _i15;
import 'package:pora/app/features/auth_and_validation/presentation/screens/auth_screen.dart'
    as _i2;
import 'package:pora/app/features/brief/presentation/screens/brief_screen.dart'
    as _i4;
import 'package:pora/app/features/deeplink_debug/deeplinks.dart' as _i6;
import 'package:pora/app/features/families/domain/entity/member.dart' as _i27;
import 'package:pora/app/features/families/presentation/screen/families_screen.dart'
    as _i7;
import 'package:pora/app/features/insights/presentation/screen/insights_screen.dart'
    as _i8;
import 'package:pora/app/features/invitation/presentation/screen/connection_to_other/household_connection_screen.dart'
    as _i9;
import 'package:pora/app/features/invitation/presentation/screen/household_screen.dart'
    as _i10;
import 'package:pora/app/features/item_detail/presentation/screen/item_detail_screen.dart'
    as _i11;
import 'package:pora/app/features/lists/presentation/screen/concrete_list_screen.dart'
    as _i12;
import 'package:pora/app/features/lists/presentation/screen/preview_lists.dart'
    as _i19;
import 'package:pora/app/features/notifications/presentation/screen/notifications_screen.dart'
    as _i14;
import 'package:pora/app/features/onboarding/presentation/screen/onboarding_slider_screen.dart'
    as _i16;
import 'package:pora/app/features/order/presentation/screen/order_screen.dart'
    as _i17;
import 'package:pora/app/features/predictions/presentation/screen/predictions_screen.dart'
    as _i18;
import 'package:pora/app/features/recipe/presentation/screen/recipe_import_screen.dart'
    as _i20;
import 'package:pora/app/features/settings/presentation/screen/settings_screen.dart'
    as _i21;
import 'package:pora/app/features/shell/presentation/screen/main_shell_screen.dart'
    as _i13;
import 'package:pora/app/features/splash/presentation/screen/splash.dart'
    as _i22;
import 'package:pora/app/features/user/presentation/screens/user_create_profile_screen.dart'
    as _i23;
import 'package:pora/app/features/welcome_back/presentation/screen/welcome_back_screen.dart'
    as _i24;

/// generated route for
/// [_i1.AddItemPage]
class AddItemRoute extends _i25.PageRouteInfo<void> {
  const AddItemRoute({List<_i25.PageRouteInfo>? children})
    : super(AddItemRoute.name, initialChildren: children);

  static const String name = 'AddItemRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddItemPage();
    },
  );
}

/// generated route for
/// [_i2.AuthPage]
class AuthRoute extends _i25.PageRouteInfo<void> {
  const AuthRoute({List<_i25.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthPage();
    },
  );
}

/// generated route for
/// [_i3.AuthWithPhone]
class AuthWithPhone extends _i25.PageRouteInfo<void> {
  const AuthWithPhone({List<_i25.PageRouteInfo>? children})
    : super(AuthWithPhone.name, initialChildren: children);

  static const String name = 'AuthWithPhone';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthWithPhone();
    },
  );
}

/// generated route for
/// [_i4.BriefPage]
class BriefRoute extends _i25.PageRouteInfo<void> {
  const BriefRoute({List<_i25.PageRouteInfo>? children})
    : super(BriefRoute.name, initialChildren: children);

  static const String name = 'BriefRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i4.BriefPage();
    },
  );
}

/// generated route for
/// [_i5.ConfirmCode]
class CodeConfirmer extends _i25.PageRouteInfo<CodeConfirmerArgs> {
  CodeConfirmer({
    _i26.Key? key,
    required int lengthOfPin,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         CodeConfirmer.name,
         args: CodeConfirmerArgs(key: key, lengthOfPin: lengthOfPin),
         initialChildren: children,
       );

  static const String name = 'CodeConfirmer';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CodeConfirmerArgs>();
      return _i5.ConfirmCode(key: args.key, lengthOfPin: args.lengthOfPin);
    },
  );
}

class CodeConfirmerArgs {
  const CodeConfirmerArgs({this.key, required this.lengthOfPin});

  final _i26.Key? key;

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
/// [_i6.DeeplinkDebugPage]
class DeeplinkDebugRoute extends _i25.PageRouteInfo<DeeplinkDebugRouteArgs> {
  DeeplinkDebugRoute({
    _i26.Key? key,
    required String linkCode,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         DeeplinkDebugRoute.name,
         args: DeeplinkDebugRouteArgs(key: key, linkCode: linkCode),
         rawPathParams: {'linkCode': linkCode},
         initialChildren: children,
       );

  static const String name = 'DeeplinkDebugRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DeeplinkDebugRouteArgs>(
        orElse: () =>
            DeeplinkDebugRouteArgs(linkCode: pathParams.getString('linkCode')),
      );
      return _i6.DeeplinkDebugPage(key: args.key, linkCode: args.linkCode);
    },
  );
}

class DeeplinkDebugRouteArgs {
  const DeeplinkDebugRouteArgs({this.key, required this.linkCode});

  final _i26.Key? key;

  final String linkCode;

  @override
  String toString() {
    return 'DeeplinkDebugRouteArgs{key: $key, linkCode: $linkCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeeplinkDebugRouteArgs) return false;
    return key == other.key && linkCode == other.linkCode;
  }

  @override
  int get hashCode => key.hashCode ^ linkCode.hashCode;
}

/// generated route for
/// [_i7.FamiliesPage]
class FamiliesRoute extends _i25.PageRouteInfo<void> {
  const FamiliesRoute({List<_i25.PageRouteInfo>? children})
    : super(FamiliesRoute.name, initialChildren: children);

  static const String name = 'FamiliesRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i7.FamiliesPage();
    },
  );
}

/// generated route for
/// [_i8.InsightsPage]
class InsightsRoute extends _i25.PageRouteInfo<void> {
  const InsightsRoute({List<_i25.PageRouteInfo>? children})
    : super(InsightsRoute.name, initialChildren: children);

  static const String name = 'InsightsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i8.InsightsPage();
    },
  );
}

/// generated route for
/// [_i9.InvitationConnectPage]
class InvitationConnectRoute
    extends _i25.PageRouteInfo<InvitationConnectRouteArgs> {
  InvitationConnectRoute({
    _i26.Key? key,
    required String linkCode,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         InvitationConnectRoute.name,
         args: InvitationConnectRouteArgs(key: key, linkCode: linkCode),
         rawPathParams: {'linkCode': linkCode},
         initialChildren: children,
       );

  static const String name = 'InvitationConnectRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<InvitationConnectRouteArgs>(
        orElse: () => InvitationConnectRouteArgs(
          linkCode: pathParams.getString('linkCode'),
        ),
      );
      return _i9.InvitationConnectPage(key: args.key, linkCode: args.linkCode);
    },
  );
}

class InvitationConnectRouteArgs {
  const InvitationConnectRouteArgs({this.key, required this.linkCode});

  final _i26.Key? key;

  final String linkCode;

  @override
  String toString() {
    return 'InvitationConnectRouteArgs{key: $key, linkCode: $linkCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InvitationConnectRouteArgs) return false;
    return key == other.key && linkCode == other.linkCode;
  }

  @override
  int get hashCode => key.hashCode ^ linkCode.hashCode;
}

/// generated route for
/// [_i10.InvitePage]
class InviteRoute extends _i25.PageRouteInfo<InviteRouteArgs> {
  InviteRoute({
    _i26.Key? key,
    required String familyId,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         InviteRoute.name,
         args: InviteRouteArgs(key: key, familyId: familyId),
         initialChildren: children,
       );

  static const String name = 'InviteRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InviteRouteArgs>();
      return _i10.InvitePage(key: args.key, familyId: args.familyId);
    },
  );
}

class InviteRouteArgs {
  const InviteRouteArgs({this.key, required this.familyId});

  final _i26.Key? key;

  final String familyId;

  @override
  String toString() {
    return 'InviteRouteArgs{key: $key, familyId: $familyId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InviteRouteArgs) return false;
    return key == other.key && familyId == other.familyId;
  }

  @override
  int get hashCode => key.hashCode ^ familyId.hashCode;
}

/// generated route for
/// [_i11.ItemDetailPage]
class ItemDetailRoute extends _i25.PageRouteInfo<void> {
  const ItemDetailRoute({List<_i25.PageRouteInfo>? children})
    : super(ItemDetailRoute.name, initialChildren: children);

  static const String name = 'ItemDetailRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i11.ItemDetailPage();
    },
  );
}

/// generated route for
/// [_i12.ListPage]
class ListRoute extends _i25.PageRouteInfo<ListRouteArgs> {
  ListRoute({
    _i26.Key? key,
    required String listId,
    String? listName,
    List<_i27.MemberEntity>? members,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ListRoute.name,
         args: ListRouteArgs(
           key: key,
           listId: listId,
           listName: listName,
           members: members,
         ),
         initialChildren: children,
       );

  static const String name = 'ListRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListRouteArgs>();
      return _i12.ListPage(
        key: args.key,
        listId: args.listId,
        listName: args.listName,
        members: args.members,
      );
    },
  );
}

class ListRouteArgs {
  const ListRouteArgs({
    this.key,
    required this.listId,
    this.listName,
    this.members,
  });

  final _i26.Key? key;

  final String listId;

  final String? listName;

  final List<_i27.MemberEntity>? members;

  @override
  String toString() {
    return 'ListRouteArgs{key: $key, listId: $listId, listName: $listName, members: $members}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListRouteArgs) return false;
    return key == other.key &&
        listId == other.listId &&
        listName == other.listName &&
        const _i28.ListEquality<_i27.MemberEntity>().equals(
          members,
          other.members,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      listId.hashCode ^
      listName.hashCode ^
      const _i28.ListEquality<_i27.MemberEntity>().hash(members);
}

/// generated route for
/// [_i13.MainShellPage]
class MainShellRoute extends _i25.PageRouteInfo<void> {
  const MainShellRoute({List<_i25.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i13.MainShellPage();
    },
  );
}

/// generated route for
/// [_i14.NotificationsPage]
class NotificationsRoute extends _i25.PageRouteInfo<void> {
  const NotificationsRoute({List<_i25.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i14.NotificationsPage();
    },
  );
}

/// generated route for
/// [_i15.OTPConfirmationPage]
class OTPConfirmationRoute
    extends _i25.PageRouteInfo<OTPConfirmationRouteArgs> {
  OTPConfirmationRoute({
    _i26.Key? key,
    required _i29.AuthStore authStore,
    required _i26.TextEditingController OTPController,
    required bool isPhone,
    required _i26.TextEditingController destinationController,
    required _i30.PrivacyStore privacyStore,
    List<_i25.PageRouteInfo>? children,
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

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OTPConfirmationRouteArgs>();
      return _i15.OTPConfirmationPage(
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

  final _i26.Key? key;

  final _i29.AuthStore authStore;

  final _i26.TextEditingController OTPController;

  final bool isPhone;

  final _i26.TextEditingController destinationController;

  final _i30.PrivacyStore privacyStore;

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
/// [_i16.OnboardingSliderPage]
class OnboardingSliderRoute extends _i25.PageRouteInfo<void> {
  const OnboardingSliderRoute({List<_i25.PageRouteInfo>? children})
    : super(OnboardingSliderRoute.name, initialChildren: children);

  static const String name = 'OnboardingSliderRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i16.OnboardingSliderPage();
    },
  );
}

/// generated route for
/// [_i17.OrderPage]
class OrderRoute extends _i25.PageRouteInfo<void> {
  const OrderRoute({List<_i25.PageRouteInfo>? children})
    : super(OrderRoute.name, initialChildren: children);

  static const String name = 'OrderRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i17.OrderPage();
    },
  );
}

/// generated route for
/// [_i18.PredictionsPage]
class PredictionsRoute extends _i25.PageRouteInfo<void> {
  const PredictionsRoute({List<_i25.PageRouteInfo>? children})
    : super(PredictionsRoute.name, initialChildren: children);

  static const String name = 'PredictionsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i18.PredictionsPage();
    },
  );
}

/// generated route for
/// [_i19.PreviewListsPage]
class PreviewListsRoute extends _i25.PageRouteInfo<PreviewListsRouteArgs> {
  PreviewListsRoute({
    _i26.Key? key,
    String? familyId,
    String? familyName,
    List<_i27.MemberEntity>? members,
    bool isPersonal = false,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         PreviewListsRoute.name,
         args: PreviewListsRouteArgs(
           key: key,
           familyId: familyId,
           familyName: familyName,
           members: members,
           isPersonal: isPersonal,
         ),
         initialChildren: children,
       );

  static const String name = 'PreviewListsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PreviewListsRouteArgs>(
        orElse: () => const PreviewListsRouteArgs(),
      );
      return _i19.PreviewListsPage(
        key: args.key,
        familyId: args.familyId,
        familyName: args.familyName,
        members: args.members,
        isPersonal: args.isPersonal,
      );
    },
  );
}

class PreviewListsRouteArgs {
  const PreviewListsRouteArgs({
    this.key,
    this.familyId,
    this.familyName,
    this.members,
    this.isPersonal = false,
  });

  final _i26.Key? key;

  final String? familyId;

  final String? familyName;

  final List<_i27.MemberEntity>? members;

  final bool isPersonal;

  @override
  String toString() {
    return 'PreviewListsRouteArgs{key: $key, familyId: $familyId, familyName: $familyName, members: $members, isPersonal: $isPersonal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PreviewListsRouteArgs) return false;
    return key == other.key &&
        familyId == other.familyId &&
        familyName == other.familyName &&
        const _i28.ListEquality<_i27.MemberEntity>().equals(
          members,
          other.members,
        ) &&
        isPersonal == other.isPersonal;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      familyId.hashCode ^
      familyName.hashCode ^
      const _i28.ListEquality<_i27.MemberEntity>().hash(members) ^
      isPersonal.hashCode;
}

/// generated route for
/// [_i20.RecipeImportPage]
class RecipeImportRoute extends _i25.PageRouteInfo<void> {
  const RecipeImportRoute({List<_i25.PageRouteInfo>? children})
    : super(RecipeImportRoute.name, initialChildren: children);

  static const String name = 'RecipeImportRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i20.RecipeImportPage();
    },
  );
}

/// generated route for
/// [_i21.SettingsPage]
class SettingsRoute extends _i25.PageRouteInfo<void> {
  const SettingsRoute({List<_i25.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i21.SettingsPage();
    },
  );
}

/// generated route for
/// [_i22.SplashPage]
class SplashRoute extends _i25.PageRouteInfo<void> {
  const SplashRoute({List<_i25.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i22.SplashPage();
    },
  );
}

/// generated route for
/// [_i23.UserCreateProfilePage]
class UserCreateProfileRoute extends _i25.PageRouteInfo<void> {
  const UserCreateProfileRoute({List<_i25.PageRouteInfo>? children})
    : super(UserCreateProfileRoute.name, initialChildren: children);

  static const String name = 'UserCreateProfileRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i23.UserCreateProfilePage();
    },
  );
}

/// generated route for
/// [_i24.WelcomeBackPage]
class WelcomeBackRoute extends _i25.PageRouteInfo<void> {
  const WelcomeBackRoute({List<_i25.PageRouteInfo>? children})
    : super(WelcomeBackRoute.name, initialChildren: children);

  static const String name = 'WelcomeBackRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i24.WelcomeBackPage();
    },
  );
}
