import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/app/internal/app/app.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]
  );

  // TODO: Initialize localization store
  final injectionContainer = InjectionContainer()..init();
  injectionContainer.getIt<LocalizationStore>().initialise();
  
  runApp(MainApp(
    injectionContainer: injectionContainer,
  ));
}
