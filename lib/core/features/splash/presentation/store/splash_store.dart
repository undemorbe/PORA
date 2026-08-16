import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/onboarding/domain/usecase/sawed_onboarding.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';
part 'splash_store.g.dart';

class SplashStore = _SplashStoreBase with _$SplashStore;

abstract class _SplashStoreBase with Store {
  @action
  Future<PageRouteInfo> whereToRoute() async {
    final auth = GetIt.instance<AuthState>();
    final sawedOnboarding = await GetIt.I<IsSawedOnboardingUseCase>().call();
    if (sawedOnboarding.isRight) {
      if (auth.status == AuthStatus.authenticated) {
        return const MainShellRoute();
      } else {
        return const AuthRoute();
      }
    } else {
      return const OnboardingSliderRoute();
    }
  }
}
