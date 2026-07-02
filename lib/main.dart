import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/app/internal/JWT_access/domain/usecases/refresh_token.dart';
import 'package:pora/app/internal/app/app.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final injectionContainer = InjectionContainer();
  await injectionContainer.init();

  await _initializeApp(injectionContainer);

  runApp(MainApp(injectionContainer: injectionContainer));
}

Future<void> _initializeApp(InjectionContainer container) async {
  final localDB = container.getIt<ILocalDB<dynamic>>();

  await localDB.init();
  await container.getIt<RefreshTokenUseCase>().call();

  final localizationStore = container.getIt<LocalizationStore>();
  await localizationStore.initialise();

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
}
