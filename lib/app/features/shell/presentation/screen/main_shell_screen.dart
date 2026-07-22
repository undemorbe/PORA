import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/internal/network/connectivity/no_internet_banner.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/widgets/pora_bottom_nav.dart';

/// Каркас приложения: floating bottom nav + connectivity banner.
///
/// `AutoTabsScaffold` — вкладки сохраняют state, ленивый build.
/// `extendBody: true` — тело уходит за плавающую панель.
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NoInternetWrapper(
      child: AutoTabsScaffold(
        extendBody: true,
        routes: [
          const GroupsRoute(),
          const PredictionsRoute(),
          const SettingsRoute(),
        ],
        transitionBuilder: (context, child, animation) =>
            FadeTransition(opacity: animation, child: child),
        bottomNavigationBuilder: (context, tabsRouter) {
          return RepaintBoundary(
            child: PoraBottomNav(
              current: PoraTab.values[tabsRouter.activeIndex],
              onTap: (tab) => tabsRouter.setActiveIndex(tab.index),
            ),
          );
        },
      ),
    );
  }
}
