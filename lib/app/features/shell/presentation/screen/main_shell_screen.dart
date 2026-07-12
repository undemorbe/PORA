import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/widgets/pora_bottom_nav.dart';

/// Каркас приложения с нижней навигацией.
///
/// Использует [AutoTabsScaffold] — вкладки сохраняют своё состояние и
/// строятся лениво (переключение без пересборки соседних вкладок), что
/// снижает джанк при навигации.
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      // Порядок должен совпадать с индексами PoraTab.
      routes: [
        FamiliesRoute(),
        const PredictionsRoute(),
        const OrderRoute(),
        const SettingsRoute(),
      ],
      // Плавная кросс-фейд-анимация между вкладками.
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
    );
  }
}
