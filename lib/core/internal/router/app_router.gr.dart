// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i26;
import 'package:collection/collection.dart' as _i29;
import 'package:flutter/material.dart' as _i27;
import 'package:pora/core/features/add_item/presentation/screen/add_item_screen.dart'
    as _i1;
import 'package:pora/core/features/auth_and_validation/presentation/controller/auth_store.dart'
    as _i30;
import 'package:pora/core/features/auth_and_validation/presentation/controller/privacy_store.dart'
    as _i31;
import 'package:pora/core/features/auth_and_validation/presentation/screens/auth_otp_confirm.dart'
    as _i15;
import 'package:pora/core/features/auth_and_validation/presentation/screens/auth_screen.dart'
    as _i3;
import 'package:pora/core/features/brief/presentation/screens/brief_screen.dart'
    as _i4;
import 'package:pora/core/features/families/domain/entity/member.dart' as _i28;
import 'package:pora/core/features/families/presentation/screen/families_screen.dart'
    as _i5;
import 'package:pora/core/features/families/presentation/screen/members_screen.dart'
    as _i13;
import 'package:pora/core/features/groups/presentation/screen/groups_screen.dart'
    as _i6;
import 'package:pora/core/features/insights/presentation/screen/insights_screen.dart'
    as _i7;
import 'package:pora/core/features/invitation/presentation/screen/connection_to_other/household_connection_screen.dart'
    as _i8;
import 'package:pora/core/features/invitation/presentation/screen/household_screen.dart'
    as _i9;
import 'package:pora/core/features/item_detail/presentation/screen/item_detail_screen.dart'
    as _i10;
import 'package:pora/core/features/lists/presentation/screen/concrete_list_screen.dart'
    as _i11;
import 'package:pora/core/features/lists/presentation/screen/preview_lists.dart'
    as _i19;
import 'package:pora/core/features/notifications/presentation/screen/notifications_screen.dart'
    as _i14;
import 'package:pora/core/features/onboarding/presentation/screen/onboarding_slider_screen.dart'
    as _i16;
import 'package:pora/core/features/order/presentation/screen/order_screen.dart'
    as _i17;
import 'package:pora/core/features/predictions/presentation/screen/predictions_screen.dart'
    as _i18;
import 'package:pora/core/features/recipe/presentation/screen/recipe_import_screen.dart'
    as _i20;
import 'package:pora/core/features/settings/presentation/screen/advanced_settings_screen.dart'
    as _i2;
import 'package:pora/core/features/settings/presentation/screen/settings_screen.dart'
    as _i21;
import 'package:pora/core/features/shell/presentation/screen/main_shell_screen.dart'
    as _i12;
import 'package:pora/core/features/splash/presentation/screen/splash.dart'
    as _i22;
import 'package:pora/core/features/tutorial/presentation/screen/tutorial_screen.dart'
    as _i23;
import 'package:pora/core/features/user/presentation/screens/user_create_profile_screen.dart'
    as _i24;
import 'package:pora/core/features/welcome_back/presentation/screen/welcome_back_screen.dart'
    as _i25;

/// generated route for
/// [_i1.AddItemPage]
class AddItemRoute extends _i26.PageRouteInfo<AddItemRouteArgs> {
  AddItemRoute({
    _i27.Key? key,
    required String lid,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         AddItemRoute.name,
         args: AddItemRouteArgs(key: key, lid: lid),
         initialChildren: children,
       );

  static const String name = 'AddItemRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddItemRouteArgs>();
      return _i1.AddItemPage(key: args.key, lid: args.lid);
    },
  );
}

class AddItemRouteArgs {
  const AddItemRouteArgs({this.key, required this.lid});

  final _i27.Key? key;

  final String lid;

  @override
  String toString() {
    return 'AddItemRouteArgs{key: $key, lid: $lid}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddItemRouteArgs) return false;
    return key == other.key && lid == other.lid;
  }

  @override
  int get hashCode => key.hashCode ^ lid.hashCode;
}

/// generated route for
/// [_i2.AdvancedSettingsPage]
class AdvancedSettingsRoute extends _i26.PageRouteInfo<void> {
  const AdvancedSettingsRoute({List<_i26.PageRouteInfo>? children})
    : super(AdvancedSettingsRoute.name, initialChildren: children);

  static const String name = 'AdvancedSettingsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdvancedSettingsPage();
    },
  );
}

/// generated route for
/// [_i3.AuthPage]
class AuthRoute extends _i26.PageRouteInfo<void> {
  const AuthRoute({List<_i26.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthPage();
    },
  );
}

/// generated route for
/// [_i4.BriefPage]
class BriefRoute extends _i26.PageRouteInfo<void> {
  const BriefRoute({List<_i26.PageRouteInfo>? children})
    : super(BriefRoute.name, initialChildren: children);

  static const String name = 'BriefRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i4.BriefPage();
    },
  );
}

/// generated route for
/// [_i5.FamiliesPage]
class FamiliesRoute extends _i26.PageRouteInfo<void> {
  const FamiliesRoute({List<_i26.PageRouteInfo>? children})
    : super(FamiliesRoute.name, initialChildren: children);

  static const String name = 'FamiliesRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i5.FamiliesPage();
    },
  );
}

/// generated route for
/// [_i6.GroupsPage]
class GroupsRoute extends _i26.PageRouteInfo<void> {
  const GroupsRoute({List<_i26.PageRouteInfo>? children})
    : super(GroupsRoute.name, initialChildren: children);

  static const String name = 'GroupsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i6.GroupsPage();
    },
  );
}

/// generated route for
/// [_i7.InsightsPage]
class InsightsRoute extends _i26.PageRouteInfo<void> {
  const InsightsRoute({List<_i26.PageRouteInfo>? children})
    : super(InsightsRoute.name, initialChildren: children);

  static const String name = 'InsightsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i7.InsightsPage();
    },
  );
}

/// generated route for
/// [_i8.InvitationConnectPage]
class InvitationConnectRoute
    extends _i26.PageRouteInfo<InvitationConnectRouteArgs> {
  InvitationConnectRoute({
    _i27.Key? key,
    required String linkCode,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         InvitationConnectRoute.name,
         args: InvitationConnectRouteArgs(key: key, linkCode: linkCode),
         rawPathParams: {'linkCode': linkCode},
         initialChildren: children,
       );

  static const String name = 'InvitationConnectRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<InvitationConnectRouteArgs>(
        orElse: () => InvitationConnectRouteArgs(
          linkCode: pathParams.getString('linkCode'),
        ),
      );
      return _i8.InvitationConnectPage(key: args.key, linkCode: args.linkCode);
    },
  );
}

class InvitationConnectRouteArgs {
  const InvitationConnectRouteArgs({this.key, required this.linkCode});

  final _i27.Key? key;

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
/// [_i9.InvitePage]
class InviteRoute extends _i26.PageRouteInfo<InviteRouteArgs> {
  InviteRoute({
    _i27.Key? key,
    required String familyId,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         InviteRoute.name,
         args: InviteRouteArgs(key: key, familyId: familyId),
         initialChildren: children,
       );

  static const String name = 'InviteRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InviteRouteArgs>();
      return _i9.InvitePage(key: args.key, familyId: args.familyId);
    },
  );
}

class InviteRouteArgs {
  const InviteRouteArgs({this.key, required this.familyId});

  final _i27.Key? key;

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
/// [_i10.ItemDetailPage]
class ItemDetailRoute extends _i26.PageRouteInfo<ItemDetailRouteArgs> {
  ItemDetailRoute({
    _i27.Key? key,
    required String itemId,
    required _i27.VoidCallback additionalEffectOnDeletion,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         ItemDetailRoute.name,
         args: ItemDetailRouteArgs(
           key: key,
           itemId: itemId,
           additionalEffectOnDeletion: additionalEffectOnDeletion,
         ),
         initialChildren: children,
       );

  static const String name = 'ItemDetailRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ItemDetailRouteArgs>();
      return _i10.ItemDetailPage(
        key: args.key,
        itemId: args.itemId,
        additionalEffectOnDeletion: args.additionalEffectOnDeletion,
      );
    },
  );
}

class ItemDetailRouteArgs {
  const ItemDetailRouteArgs({
    this.key,
    required this.itemId,
    required this.additionalEffectOnDeletion,
  });

  final _i27.Key? key;

  final String itemId;

  final _i27.VoidCallback additionalEffectOnDeletion;

  @override
  String toString() {
    return 'ItemDetailRouteArgs{key: $key, itemId: $itemId, additionalEffectOnDeletion: $additionalEffectOnDeletion}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ItemDetailRouteArgs) return false;
    return key == other.key &&
        itemId == other.itemId &&
        additionalEffectOnDeletion == other.additionalEffectOnDeletion;
  }

  @override
  int get hashCode =>
      key.hashCode ^ itemId.hashCode ^ additionalEffectOnDeletion.hashCode;
}

/// generated route for
/// [_i11.ListPage]
class ListRoute extends _i26.PageRouteInfo<ListRouteArgs> {
  ListRoute({
    _i27.Key? key,
    required String listId,
    String? listName,
    List<_i28.MemberEntity>? members,
    List<_i26.PageRouteInfo>? children,
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

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ListRouteArgs>();
      return _i11.ListPage(
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

  final _i27.Key? key;

  final String listId;

  final String? listName;

  final List<_i28.MemberEntity>? members;

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
        const _i29.ListEquality<_i28.MemberEntity>().equals(
          members,
          other.members,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      listId.hashCode ^
      listName.hashCode ^
      const _i29.ListEquality<_i28.MemberEntity>().hash(members);
}

/// generated route for
/// [_i12.MainShellPage]
class MainShellRoute extends _i26.PageRouteInfo<void> {
  const MainShellRoute({List<_i26.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i12.MainShellPage();
    },
  );
}

/// generated route for
/// [_i13.MembersPage]
class MembersRoute extends _i26.PageRouteInfo<MembersRouteArgs> {
  MembersRoute({
    _i27.Key? key,
    required List<_i28.MemberEntity> members,
    String? ownerId,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         MembersRoute.name,
         args: MembersRouteArgs(key: key, members: members, ownerId: ownerId),
         initialChildren: children,
       );

  static const String name = 'MembersRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MembersRouteArgs>();
      return _i13.MembersPage(
        key: args.key,
        members: args.members,
        ownerId: args.ownerId,
      );
    },
  );
}

class MembersRouteArgs {
  const MembersRouteArgs({this.key, required this.members, this.ownerId});

  final _i27.Key? key;

  final List<_i28.MemberEntity> members;

  final String? ownerId;

  @override
  String toString() {
    return 'MembersRouteArgs{key: $key, members: $members, ownerId: $ownerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MembersRouteArgs) return false;
    return key == other.key &&
        const _i29.ListEquality<_i28.MemberEntity>().equals(
          members,
          other.members,
        ) &&
        ownerId == other.ownerId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i29.ListEquality<_i28.MemberEntity>().hash(members) ^
      ownerId.hashCode;
}

/// generated route for
/// [_i14.NotificationsPage]
class NotificationsRoute extends _i26.PageRouteInfo<void> {
  const NotificationsRoute({List<_i26.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i14.NotificationsPage();
    },
  );
}

/// generated route for
/// [_i15.OTPConfirmationPage]
class OTPConfirmationRoute
    extends _i26.PageRouteInfo<OTPConfirmationRouteArgs> {
  OTPConfirmationRoute({
    _i27.Key? key,
    required _i30.AuthStore authStore,
    required _i27.TextEditingController OTPController,
    required bool isPhone,
    required _i27.TextEditingController destinationController,
    required _i31.PrivacyStore privacyStore,
    List<_i26.PageRouteInfo>? children,
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

  static _i26.PageInfo page = _i26.PageInfo(
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

  final _i27.Key? key;

  final _i30.AuthStore authStore;

  final _i27.TextEditingController OTPController;

  final bool isPhone;

  final _i27.TextEditingController destinationController;

  final _i31.PrivacyStore privacyStore;

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
class OnboardingSliderRoute extends _i26.PageRouteInfo<void> {
  const OnboardingSliderRoute({List<_i26.PageRouteInfo>? children})
    : super(OnboardingSliderRoute.name, initialChildren: children);

  static const String name = 'OnboardingSliderRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i16.OnboardingSliderPage();
    },
  );
}

/// generated route for
/// [_i17.OrderPage]
class OrderRoute extends _i26.PageRouteInfo<void> {
  const OrderRoute({List<_i26.PageRouteInfo>? children})
    : super(OrderRoute.name, initialChildren: children);

  static const String name = 'OrderRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i17.OrderPage();
    },
  );
}

/// generated route for
/// [_i18.PredictionsPage]
class PredictionsRoute extends _i26.PageRouteInfo<void> {
  const PredictionsRoute({List<_i26.PageRouteInfo>? children})
    : super(PredictionsRoute.name, initialChildren: children);

  static const String name = 'PredictionsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i18.PredictionsPage();
    },
  );
}

/// generated route for
/// [_i19.PreviewListsPage]
class PreviewListsRoute extends _i26.PageRouteInfo<PreviewListsRouteArgs> {
  PreviewListsRoute({
    _i27.Key? key,
    String? familyId,
    String? familyName,
    List<_i28.MemberEntity>? members,
    bool isPersonal = false,
    List<_i26.PageRouteInfo>? children,
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

  static _i26.PageInfo page = _i26.PageInfo(
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

  final _i27.Key? key;

  final String? familyId;

  final String? familyName;

  final List<_i28.MemberEntity>? members;

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
        const _i29.ListEquality<_i28.MemberEntity>().equals(
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
      const _i29.ListEquality<_i28.MemberEntity>().hash(members) ^
      isPersonal.hashCode;
}

/// generated route for
/// [_i20.RecipeImportPage]
class RecipeImportRoute extends _i26.PageRouteInfo<RecipeImportRouteArgs> {
  RecipeImportRoute({
    _i27.Key? key,
    required String lid,
    String? fid,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         RecipeImportRoute.name,
         args: RecipeImportRouteArgs(key: key, lid: lid, fid: fid),
         initialChildren: children,
       );

  static const String name = 'RecipeImportRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecipeImportRouteArgs>();
      return _i20.RecipeImportPage(key: args.key, lid: args.lid, fid: args.fid);
    },
  );
}

class RecipeImportRouteArgs {
  const RecipeImportRouteArgs({this.key, required this.lid, this.fid});

  final _i27.Key? key;

  final String lid;

  final String? fid;

  @override
  String toString() {
    return 'RecipeImportRouteArgs{key: $key, lid: $lid, fid: $fid}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecipeImportRouteArgs) return false;
    return key == other.key && lid == other.lid && fid == other.fid;
  }

  @override
  int get hashCode => key.hashCode ^ lid.hashCode ^ fid.hashCode;
}

/// generated route for
/// [_i21.SettingsPage]
class SettingsRoute extends _i26.PageRouteInfo<void> {
  const SettingsRoute({List<_i26.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i21.SettingsPage();
    },
  );
}

/// generated route for
/// [_i22.SplashPage]
class SplashRoute extends _i26.PageRouteInfo<void> {
  const SplashRoute({List<_i26.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i22.SplashPage();
    },
  );
}

/// generated route for
/// [_i23.TutorialPage]
class TutorialRoute extends _i26.PageRouteInfo<TutorialRouteArgs> {
  TutorialRoute({
    _i27.Key? key,
    bool fromSettings = false,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         TutorialRoute.name,
         args: TutorialRouteArgs(key: key, fromSettings: fromSettings),
         initialChildren: children,
       );

  static const String name = 'TutorialRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TutorialRouteArgs>(
        orElse: () => const TutorialRouteArgs(),
      );
      return _i23.TutorialPage(key: args.key, fromSettings: args.fromSettings);
    },
  );
}

class TutorialRouteArgs {
  const TutorialRouteArgs({this.key, this.fromSettings = false});

  final _i27.Key? key;

  final bool fromSettings;

  @override
  String toString() {
    return 'TutorialRouteArgs{key: $key, fromSettings: $fromSettings}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TutorialRouteArgs) return false;
    return key == other.key && fromSettings == other.fromSettings;
  }

  @override
  int get hashCode => key.hashCode ^ fromSettings.hashCode;
}

/// generated route for
/// [_i24.UserCreateProfilePage]
class UserCreateProfileRoute
    extends _i26.PageRouteInfo<UserCreateProfileRouteArgs> {
  UserCreateProfileRoute({
    _i27.Key? key,
    bool isUpdating = false,
    List<_i26.PageRouteInfo>? children,
  }) : super(
         UserCreateProfileRoute.name,
         args: UserCreateProfileRouteArgs(key: key, isUpdating: isUpdating),
         initialChildren: children,
       );

  static const String name = 'UserCreateProfileRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserCreateProfileRouteArgs>(
        orElse: () => const UserCreateProfileRouteArgs(),
      );
      return _i24.UserCreateProfilePage(
        key: args.key,
        isUpdating: args.isUpdating,
      );
    },
  );
}

class UserCreateProfileRouteArgs {
  const UserCreateProfileRouteArgs({this.key, this.isUpdating = false});

  final _i27.Key? key;

  final bool isUpdating;

  @override
  String toString() {
    return 'UserCreateProfileRouteArgs{key: $key, isUpdating: $isUpdating}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserCreateProfileRouteArgs) return false;
    return key == other.key && isUpdating == other.isUpdating;
  }

  @override
  int get hashCode => key.hashCode ^ isUpdating.hashCode;
}

/// generated route for
/// [_i25.WelcomeBackPage]
class WelcomeBackRoute extends _i26.PageRouteInfo<void> {
  const WelcomeBackRoute({List<_i26.PageRouteInfo>? children})
    : super(WelcomeBackRoute.name, initialChildren: children);

  static const String name = 'WelcomeBackRoute';

  static _i26.PageInfo page = _i26.PageInfo(
    name,
    builder: (data) {
      return const _i25.WelcomeBackPage();
    },
  );
}
