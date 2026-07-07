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
    // Каркас с нижней навигацией; вкладки — вложенные маршруты.
    AutoRoute(
      page: MainShellRoute.page,
      path: "/main",
      guards: [_authGuard],
      children: [
        AutoRoute(page: HomeRoute.page, path: "list", initial: true),
        AutoRoute(page: PredictionsRoute.page, path: "pora"),
        AutoRoute(page: OrderRoute.page, path: "order"),
        AutoRoute(page: SettingsRoute.page, path: "profile"),
      ],
    ),
    // Детальные экраны — поверх каркаса (полноэкранные, со своей «назад»).
    AutoRoute(
      page: ItemDetailRoute.page,
      path: "/${ItemDetailRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: AddItemRoute.page,
      path: "/${AddItemRoute.name}",
      guards: [_authGuard],
    ),
    AutoRoute(
      page: HouseholdRoute.page,
      path: "/${HouseholdRoute.name}",
      guards: [_authGuard],
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
    // AutoRoute(
    //   page: FamiliesRoute.page,
    //   path: "/${FamiliesRoute.name}",
    //   guards: [_authGuard],
    // ),
    AutoRoute(page: BriefRoute.page, path: "/${BriefRoute.name}"),
    AutoRoute(page: BriefProfileRoute.page, path: "/${BriefProfileRoute.name}"),
  ];
}
