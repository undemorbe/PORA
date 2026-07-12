import 'package:auto_route/auto_route.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/router/guard/auth_guard.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this._auth);

  final AuthState _auth;
  late final AuthGuard _authGuard = AuthGuard(_auth);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      path: "/${SplashRoute.name}",
      initial: true,
    ),
    AutoRoute(page: AuthRoute.page, path: "/${AuthRoute.name}"),
    AutoRoute(
      page: OTPConfirmationRoute.page,
      path: "/${OTPConfirmationRoute.name}",
    ),
    AutoRoute(page: WelcomeBackRoute.page, path: "/${WelcomeBackRoute.name}"),
    AutoRoute(
      page: MainShellRoute.page,
      path: "/main",
      guards: [_authGuard],
      children: [
        AutoRoute(page: FamiliesRoute.page, path: "family_list", initial: true),
        AutoRoute(page: PredictionsRoute.page, path: "pora"),
        AutoRoute(page: OrderRoute.page, path: "order"),
        AutoRoute(page: SettingsRoute.page, path: "profile"),
      ],
    ),
    AutoRoute(
      page: ItemDetailRoute.page,
      path: "/${ItemDetailRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: ListRoute.page,
      path: "/${ListRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: AddItemRoute.page,
      path: "/${AddItemRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: InviteRoute.page,
      path: "/${InviteRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: InvitationConnectRoute.page,
      path: "/api/families/join/:link_code",
    ),

    AutoRoute(
      page: RecipeImportRoute.page,
      path: "/${RecipeImportRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: InsightsRoute.page,
      path: "/${InsightsRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: NotificationsRoute.page,
      path: "/${NotificationsRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: SearchRoute.page,
      path: "/${SearchRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: OnboardingSliderRoute.page,
      path: "/${OnboardingSliderRoute.name}",
    ),
    AutoRoute(page: BriefRoute.page, path: "/${BriefRoute.name}"),
    AutoRoute(
      page: UserCreateProfileRoute.page,
      path: "/${UserCreateProfileRoute.name}",
    ),
  ];
}
