import 'package:pora/app/features/families/data/datasource/remote/family_remote.dart';
import 'package:pora/app/features/families/data/service/family_service.dart';
import 'package:pora/app/features/families/domain/repository/family_repository.dart';
import 'package:pora/app/features/families/domain/usecase/create_family.dart';
import 'package:pora/app/features/families/domain/usecase/delete_family.dart';
import 'package:pora/app/features/families/domain/usecase/get_families.dart';
import 'package:pora/app/internal/share/share_conf.dart';

import 'export.dart';

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
    _getIt.registerSingleton<AuthState>(AuthState());
    _getIt.registerSingleton<AppRouter>(AppRouter(_getIt<AuthState>()));
    _getIt.registerSingleton<ThemeStore>(ThemeStore());
    _getIt.registerLazySingleton<TokensSecureStore>(() => TokensSecureStore());

    //! NETWORK
    _getIt.registerLazySingleton<Dio>(() => DioClient.instance);
    _getIt.registerLazySingleton<ApiClient>(() => ApiClient(_getIt<Dio>()));
    _getIt.registerLazySingleton<IUriLauncher>(() => UriLauncherImpl());

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
    _getIt.registerFactory<SaveTokensUseCase>(
      () => SaveTokensUseCase(tokensRepository: _getIt<TokensRepository>()),
    );

    //! USER feature
    _getIt.registerFactory<GetUserUseCase>(
      () => GetUserUseCase(_getIt<UserRepository>()),
    );
    _getIt.registerFactory<UpdateUserUseCase>(
      () => UpdateUserUseCase(_getIt<UserRepository>()),
    );

    //! Auth(otp) feature
    _getIt.registerFactory<SendOtpUseCase>(
      () => SendOtpUseCase(authRepository: _getIt<AuthRepository>()),
    );
    _getIt.registerFactory<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(authRepository: _getIt<AuthRepository>()),
    );

    //! Onboarding feature
    _getIt.registerFactory<IsSawedOnboardingUseCase>(
      () => IsSawedOnboardingUseCase(
        onboardingRepository: _getIt<OnboardingRepository>(),
      ),
    );
    _getIt.registerFactory<UpdateIsSawedOnboardingUseCase>(
      () => UpdateIsSawedOnboardingUseCase(
        onboardingRepository: _getIt<OnboardingRepository>(),
      ),
    );

    //! Families
    _getIt.registerFactory<GetFamiliesUseCase>(
      () => GetFamiliesUseCase(familyRepository: _getIt<FamilyRepository>()),
    );
    _getIt.registerFactory<CreateFamilyUseCase>(
      () => CreateFamilyUseCase(familyRepository: _getIt<FamilyRepository>()),
    );
    _getIt.registerFactory<DeleteFamilyUseCase>(
      () => DeleteFamilyUseCase(familyRepository: _getIt<FamilyRepository>()),
    );

    //! Invitations (linkCodes for families)
    _getIt.registerFactory<GetInviteCodeUseCase>(
      () => GetInviteCodeUseCase(
        invitationsRepository: _getIt<InvitationsRepository>(),
      ),
    );
    _getIt.registerFactory<ConnectWithInviteCodeUseCase>(
      () => ConnectWithInviteCodeUseCase(
        invitationsRepository: _getIt<InvitationsRepository>(),
      ),
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
    //? Might be good to Fix secure store to clean architecture, impl, abstract etc
    _getIt.registerLazySingleton<TokensRepository>(
      () => TokensService(
        tokensRemoteDataSource: _getIt<TokensRemoteDataSource>(),
        tokensSecureStore: _getIt<TokensSecureStore>(),
      ),
    );

    //! Auth(otp) feature
    _getIt.registerLazySingleton<AuthRemote>(
      () => AuthRemoteImpl(apiClient: _getIt<ApiClient>()),
    );
    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthService(authRemote: _getIt<AuthRemote>()),
    );

    //! ONBOARDING feature
    _getIt.registerLazySingleton<OnboardingLocalDataSourceImpl>(
      () => OnboardingLocalDataSourceImpl(iLocalDB: _getIt<ILocalDB>()),
    );
    _getIt.registerLazySingleton<OnboardingRepository>(
      () => OnboardingService(
        onboardingLocaleDataSource: _getIt<OnboardingLocalDataSourceImpl>(),
      ),
    );

    //! Families
    _getIt.registerLazySingleton<FamilyRemoteDataSource>(
      () => FamilyRemoteDataSourceImpl(apiClient: _getIt<ApiClient>()),
    );
    _getIt.registerLazySingleton<FamilyRepository>(
      () => FamilyService(
        familyRemoteDataSource: _getIt<FamilyRemoteDataSource>(),
      ),
    );

    //! Invitations (linkCodes to families)
    _getIt.registerLazySingleton<RemoteInvitations>(
      () => RemoteInvitationsImpl(apiClient: _getIt<ApiClient>()),
    );
    _getIt.registerLazySingleton<InvitationsRepository>(
      () => InvitationsService(remoteInvitations: _getIt<RemoteInvitations>()),
    );

    //! Sharing
    _getIt.registerLazySingleton<SharingRepository>(
      () => SharingRepositoryImpl(),
    );
  }
}
