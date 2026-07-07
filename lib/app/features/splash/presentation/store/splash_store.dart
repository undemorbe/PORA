import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/onboarding/domain/usecase/sawed_onboarding.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';
part 'splash_store.g.dart';

class SplashStore = _SplashStoreBase with _$SplashStore;

abstract class _SplashStoreBase with Store {
  @action
  Future<PageRouteInfo> whereToRoute() async {
    final authed = GetIt.instance<AuthState>().isAuthenticated;
    final sawedOnboarding = await GetIt.I<IsSawedOnboardingUseCase>().call();
    if (sawedOnboarding.isRight) {
      final routeDestination = authed
          ? const MainShellRoute()
          : sawedOnboarding.right
          ? const AuthRoute()
          : const OnboardingSliderRoute();
      return routeDestination;
    }
    return const OnboardingSliderRoute();
  }
}
