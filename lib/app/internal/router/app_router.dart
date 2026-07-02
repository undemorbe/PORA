import 'package:auto_route/auto_route.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      path: "/${SplashRoute.name}",
      initial: true,
    ),
    AutoRoute(page: AuthWithPhone.page, path: "/${AuthWithPhone.name}"),
    AutoRoute(page: AuthRoute.page, path: "/${AuthRoute.name}"),
    AutoRoute(page: HomeRoute.page, path: "/${HomeRoute.name}"),
    AutoRoute(page: PredictionsRoute.page, path: "/${PredictionsRoute.name}"),
    AutoRoute(
      page: OnboardingBriefRoute.page,
      path: "/${OnboardingBriefRoute.name}",
    ),
    AutoRoute(page: SettingsRoute.page, path: "/${SettingsRoute.name}"),
    AutoRoute(page: ItemDetailRoute.page, path: "/${ItemDetailRoute.name}"),
    AutoRoute(page: AddItemRoute.page, path: "/${AddItemRoute.name}"),
    AutoRoute(page: HouseholdRoute.page, path: "/${HouseholdRoute.name}"),
    AutoRoute(page: RecipeImportRoute.page, path: "/${RecipeImportRoute.name}"),
    AutoRoute(page: InsightsRoute.page, path: "/${InsightsRoute.name}"),
    AutoRoute(
      page: NotificationsRoute.page,
      path: "/${NotificationsRoute.name}",
    ),
    AutoRoute(page: OrderRoute.page, path: "/${OrderRoute.name}"),
    AutoRoute(page: SearchRoute.page, path: "/${SearchRoute.name}"),
    AutoRoute(
      page: OnboardingSliderRoute.page,
      path: "/${OnboardingSliderRoute.name}",
    ),
  ];
}
