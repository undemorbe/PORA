import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/app/internal/localization/l10n/locales.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/router/app_router.dart';
import 'package:pora/app/internal/theme/app_themes.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.injectionContainer});
  final InjectionContainer injectionContainer;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      //!App Info
      title: 'PORA',
      debugShowCheckedModeBanner: false,
      
      //!Routing
      routerDelegate: AutoRouterDelegate(
      injectionContainer.getIt<AppRouter>(),
      navigatorObservers: () => [
        TalkerRouteObserver(Logger.talker),
       ],
  ),
      

      //! Theme
      darkTheme: PoraTheme.dark,
      theme: PoraTheme.light,
      // To change theme, must go to settings in iOS
      themeMode: ThemeMode.system,
      

      // !Localization
      supportedLocales: Locales.supportedLocales,
      // To change locale must go to settings in iOS or inapp settings
      locale: Locale(injectionContainer.getIt<LocalizationStore>().currentLocale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
