import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/app/internal/localization/l10n/locales.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/router/app_router.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';
import 'package:pora/app/internal/theme/app_themes.dart';
import 'package:pora/app/internal/theme/store/theme_store.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.injectionContainer});
  final InjectionContainer injectionContainer;

  @override
  Widget build(BuildContext context) {
    final router = injectionContainer.getIt<AppRouter>();
    final themeStore = injectionContainer.getIt<ThemeStore>();
    final localeStore = injectionContainer.getIt<LocalizationStore>();

    return Observer(
      builder: (context) => MaterialApp.router(
        title: 'PORA',
        debugShowCheckedModeBanner: false,

        //!Routing
        routerConfig: router.config(
          navigatorObservers: () => [TalkerRouteObserver(Logger.talker)],
          reevaluateListenable: ReevaluateListenable.stream(
            injectionContainer.getIt<AuthState>().stream,
          ),
          deepLinkBuilder: (deepLink) {
            Logger.talker.debug(deepLink.path);
            if (deepLink.path.contains('/api/families/join')) {
              final segments = deepLink.uri.pathSegments;
              final code = segments.isNotEmpty ? segments.last : '';
              return DeepLink([
                const FamiliesRoute(),
                InvitationConnectRoute(linkCode: code),
              ]);
            } else {
              return DeepLink.defaultPath;
            }
          },
        ),

        //! Theme (Observer перерисует при смене mode).
        theme: PoraTheme.light,
        darkTheme: PoraTheme.dark,
        themeMode: themeStore.themeMode,

        //! Themed transitions — плавная смена темы.
        themeAnimationDuration: const Duration(milliseconds: 320),
        themeAnimationCurve: Curves.easeOutCubic,

        //! Localization.
        supportedLocales: Locales.supportedLocales,
        locale: Locale(localeStore.currentLocale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
