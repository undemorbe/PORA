import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/core/internal/app/app.dart';
import 'package:pora/core/internal/bootstrap/app_bootstrap.dart';
import 'package:pora/core/internal/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Быстрая часть: DI-регистрации + dotenv (~10-50ms).
  final injectionContainer = InjectionContainer();
  await injectionContainer.init();

  // System chrome — синхронно, копейки.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Тяжёлая часть (Hive/Firebase/FCM/refresh/локализация) уходит в фон.
  // Splash её дождётся перед навигацией.
  AppBootstrap.instance.start(injectionContainer);

  runApp(MainApp(injectionContainer: injectionContainer));
}
