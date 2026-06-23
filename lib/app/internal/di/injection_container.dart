
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
import 'package:pora/app/internal/local_storage/hive_local_db.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/router/app_router.dart';

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
    _getIt.registerSingleton<LocalDBInterface<dynamic>>(
      HiveLocalDB<dynamic>(),
    );

    //! Environment variables
    await dotenv.load();

    //! Settings for app

    //Localization
    _getIt.registerSingleton<LocalizationStore>(LocalizationStore());
  }



}
