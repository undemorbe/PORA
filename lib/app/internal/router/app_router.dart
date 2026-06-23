import 'package:auto_route/auto_route.dart';
import 'package:pora/app/features/splash/presentation/screen/splash.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: SplashRoute.name,),
  ];
}