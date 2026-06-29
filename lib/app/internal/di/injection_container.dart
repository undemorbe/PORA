
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/app/internal/JWT_access/data/jwt_api.dart';
import 'package:pora/app/internal/JWT_access/store/JWT_store.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
import 'package:pora/app/internal/local_storage/hive_local_db.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/network/network_abstract.dart';
import 'package:pora/app/internal/router/app_router.dart';
import 'package:pora/app/internal/theme/store/theme_store.dart';

/// Dependency injection container
class InjectionContainer {

  final _getIt = GetIt.instance;

  GetIt get getIt => _getIt;

  Future<void> init() async {
    // TODO: Initialize dependencies here

    //! Routing
    _getIt.registerSingleton<AppRouter>(
      AppRouter(),
    );

    //! LocalStorage
    _getIt.registerSingleton<ILocalDB<dynamic>>(
      HiveLocalDB<dynamic>(),
    );

    //! Network
    _getIt.registerSingleton<INetworkService>(
      DioNetworkService(),
    );

    //! Environment variables
    await dotenv.load();

    //! Settings for app

    //! Localization
    _getIt.registerSingleton<LocalizationStore>(LocalizationStore());
    
    //! Theme
    _getIt.registerSingleton<ThemeStore>(ThemeStore());

    //! RefreshTokens
    _getIt.registerSingleton<IRefreshTokensRequest>(
      RefreshTokensRequest(networkService: _getIt<INetworkService>()),
    );

    _getIt.registerSingleton<JWTAccessStore>(JWTAccessStore(
      refreshTokensRequest: _getIt<IRefreshTokensRequest>(),
      localDB: _getIt<ILocalDB<dynamic>>(),
    ));
  }



}
