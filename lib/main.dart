import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/core/internal/app/app.dart';
import 'package:pora/core/internal/bootstrap/app_bootstrap.dart';
import 'package:pora/core/internal/di/injection_container.dart';
import 'package:pora/core/internal/errors/error_zone.dart';

void main() {
  ErrorZone.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final injectionContainer = InjectionContainer();
    await injectionContainer.init();
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
    AppBootstrap.instance.start(injectionContainer);
    runApp(MainApp(injectionContainer: injectionContainer));
  });
}
