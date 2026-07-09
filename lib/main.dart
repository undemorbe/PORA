import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pora/app/features/auth_and_validation/data/datasource/local/secure_tokens.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/refresh_token.dart';
import 'package:pora/app/internal/app/app.dart';
import 'package:pora/app/internal/di/injection_container.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';
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
  final refreshed = await container.getIt<RefreshTokenUseCase>().call();
  final auth = container.getIt<AuthState>();
  (refreshed?.isRight ?? false)
      ? auth.setAuthenticated()
      : auth.setUnauthenticated();

  // Наполняем sync-кэш токена для AuthInterceptor при холодном старте
  // (иначе до первого saveTokens Authorization не подставляется).
  final tokensStore = container.getIt<TokensSecureStore>();
  tokensStore.updateCache(await tokensStore.getAccessToken());

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
