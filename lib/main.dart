import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/app/internal/JWT_access/store/JWT_store.dart';
import 'package:pora/app/internal/app/app.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final injectionContainer = InjectionContainer()..init();

  await injectionContainer.getIt<ILocalDB<dynamic>>().init();
  await injectionContainer.getIt<JWTAccessStore>().fetchAccessToken();

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

  
  injectionContainer.getIt<LocalizationStore>().initialise();
  
  runApp(MainApp(
    injectionContainer: injectionContainer,
  ));
}
