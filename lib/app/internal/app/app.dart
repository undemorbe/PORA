import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/app/internal/localization/l10n/locales.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/theme/app_themes.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.injectionContainer});
  final InjectionContainer injectionContainer;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //!App Info
      title: 'PORA',
      debugShowCheckedModeBanner: false,
      
      //!Routing

      //! Theme
      darkTheme: PoraTheme.dark,
      theme: PoraTheme.light,
      //? To change theme, must go to settings in iOS
      themeMode: ThemeMode.system,

      // !Localization
      supportedLocales: Locales.supportedLocales,
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
