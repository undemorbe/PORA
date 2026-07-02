import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/app/features/user/data/datasource/remote.dart';
import 'package:pora/app/features/user/data/services/user/user_service.dart';
import 'package:pora/app/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/app/features/user/domain/usecase/user/get_user.dart';
import 'package:pora/app/features/user/domain/usecase/user/update_user.dart';
import 'package:pora/app/internal/JWT_access/data/datasource/local/secure.dart';
import 'package:pora/app/internal/JWT_access/data/datasource/remote/remote_tokens.dart';
import 'package:pora/app/internal/JWT_access/data/services/tokens_service.dart';
import 'package:pora/app/internal/JWT_access/domain/repositories/tokens_repository.dart';
import 'package:pora/app/internal/JWT_access/domain/usecases/refresh_token.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
import 'package:pora/app/internal/local_storage/hive_local_db.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';
import 'package:pora/app/internal/network/api_client/dio.dart';
import 'package:pora/app/internal/router/app_router.dart';
import 'package:pora/app/internal/theme/store/theme_store.dart';

class InjectionContainer {
  final _getIt = GetIt.instance;
  GetIt get getIt => _getIt;

  Future<void> init() async {
    await dotenv.load();
    _registerCoreDependencies();
    _registerRepositories();
    _registerUsecases();
    await _getIt.allReady();
    try {
      Logger.talker.info('Dependencies initialized successfully');
    } catch (e, stackTrace) {
      Logger.talker.error('Failed to initialize dependencies', e, stackTrace);
      rethrow;
    }
  }

  void _registerCoreDependencies() {
    _getIt.registerSingleton<LocalizationStore>(LocalizationStore());
    _getIt.registerSingleton<AppRouter>(AppRouter());
    _getIt.registerSingleton<ThemeStore>(ThemeStore());
    _getIt.registerLazySingleton<TokensSecureStore>(() => TokensSecureStore());

    //! NETWORK
    _getIt.registerLazySingleton<Dio>(() => DioClient.instance);
    _getIt.registerLazySingleton<ApiClient>(() => ApiClient(_getIt<Dio>()));

    //! STORAGE
    _getIt.registerSingletonAsync<ILocalDB<dynamic>>(
      () async => HiveLocalDB<dynamic>()..init(),
    );
  }

  void _registerUsecases() {
    //! JWT (tokens) feature
    _getIt.registerFactory<RefreshTokenUseCase>(
      () => RefreshTokenUseCase(tokensRepository: _getIt<TokensRepository>()),
    );

    //! USER feature
    _getIt.registerLazySingleton<GetUser>(
      () => GetUser(_getIt<UserRepository>()),
    );
    _getIt.registerLazySingleton<UpdateUser>(
      () => UpdateUser(_getIt<UserRepository>()),
    );
  }

  void _registerRepositories() {
    //! USER feature
    _getIt.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(_getIt<ApiClient>()),
    );
    _getIt.registerLazySingleton<UserRepository>(
      () => UserService(_getIt<UserRemoteDataSource>()),
    );

    //! JWT (tokens) feature
    _getIt.registerLazySingleton<TokensRemoteDataSource>(
      () => TokensRemoteDataSourceImpl(apiClient: _getIt<ApiClient>()),
    );
    //? Fix secure store to clean architecture, impl, abstract etc
    _getIt.registerLazySingleton<TokensRepository>(
      () => TokensService(
        tokensRemoteDataSource: _getIt<TokensRemoteDataSource>(),
        tokensSecureStore: _getIt<TokensSecureStore>(),
      ),
    );
  }
}
