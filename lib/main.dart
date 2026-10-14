import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/core/internal/app/app.dart';
import 'package:pora/core/internal/bootstrap/app_bootstrap.dart';
import 'package:pora/core/internal/di/injection_container.dart';
import 'package:pora/core/internal/errors/error_zone.dart';

void main() {
  ErrorZone.run(() async {
    // Ставит device_preview-биндинг (в release эквивалентно
    // WidgetsFlutterBinding.ensureInitialized). Управление — вкладка
    // "Device Preview" в Dart DevTools.
    DevicePreview.enable(enabled: !kReleaseMode);
    final injectionContainer = InjectionContainer();
    await injectionContainer.init();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AppBootstrap.instance.start(injectionContainer);
    runApp(MainApp(injectionContainer: injectionContainer));
  });
}
