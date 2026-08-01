import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/widgets/pora_bottom_nav.dart';

/// Каркас приложения: floating bottom nav + connectivity banner.
///
/// `AutoTabsScaffold` — вкладки сохраняют state, ленивый build.
/// `extendBody: true` — тело уходит за плавающую панель.
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      extendBody: true,
      routes: [
        const GroupsRoute(),
        const PredictionsRoute(),
        const SettingsRoute(),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      bottomNavigationBuilder: (context, tabsRouter) {
        if(context.mounted){
          context.maybePop();
        }
        return RepaintBoundary(
          child: PoraBottomNav(
            current: PoraTab.values[tabsRouter.activeIndex],
            onTap: (tab) => tabsRouter.setActiveIndex(tab.index),
          ),
        );
      },
    );
  }
}
