import 'package:pora/app/features/brief/presentation/controller/brief_store.dart';

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
    _getIt.registerSingleton<SelectedFamilyStore>(SelectedFamilyStore());
    _getIt.registerSingleton<ConnectivityStore>(ConnectivityStore());
    _getIt.registerLazySingleton<TokensSecureStore>(() => TokensSecureStore());

    //! NETWORK
    _getIt.registerLazySingleton<Dio>(() => DioClient.instance);
    _getIt.registerLazySingleton<ApiClient>(() => ApiClient(_getIt<Dio>()));
    _getIt.registerLazySingleton<IUriLauncher>(() => UriLauncherImpl());

    //! STORAGE
    _getIt.registerSingletonAsync<ILocalDB<dynamic>>(
      () async => HiveLocalDB<dynamic>()..init(),
    );

    //! Notifications
    _getIt.registerSingleton<NotificationService>(NotificationService.instance);

    //! Image
    _getIt.registerLazySingleton<ImagePicker>(() => ImagePicker());

    _getIt.registerLazySingleton<ImageProcessingService>(
      () => ImageProcessingService(),
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
    _getIt.registerFactory<LogoutUseCase>(
      () => LogoutUseCase(repository: _getIt<UserRepository>()),
    );
    _getIt.registerFactory<UpdateDeviceTokenUseCase>(
      () => UpdateDeviceTokenUseCase(repository: _getIt<UserRepository>()),
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

    //! Lists
    _getIt.registerFactory<CreateListUseCase>(
      () => CreateListUseCase(listsRepository: _getIt<ListsRepository>()),
    );
    _getIt.registerFactory<DeleteListUseCase>(
      () => DeleteListUseCase(listsRepository: _getIt<ListsRepository>()),
    );
    _getIt.registerFactory<GetFamiliesListsUseCase>(
      () => GetFamiliesListsUseCase(listsRepository: _getIt<ListsRepository>()),
    );
    _getIt.registerFactory<GetConcreteListUseCase>(
      () => GetConcreteListUseCase(listsRepository: _getIt<ListsRepository>()),
    );

    //! Items
    _getIt.registerFactory<GetItemUseCase>(
      () => GetItemUseCase(repository: _getIt<ItemsRepository>()),
    );
    _getIt.registerFactory<AddItemUseCase>(
      () => AddItemUseCase(repository: _getIt<ItemsRepository>()),
    );
    _getIt.registerFactory<UpdateItemUseCase>(
      () => UpdateItemUseCase(repository: _getIt<ItemsRepository>()),
    );
    _getIt.registerFactory<DeleteItemUseCase>(
      () => DeleteItemUseCase(repository: _getIt<ItemsRepository>()),
    );
    _getIt.registerFactory<NotifyAboutItemUseCase>(
      () => NotifyAboutItemUseCase(repository: _getIt<ItemsRepository>()),
    );
    _getIt.registerFactory<MarkItemBoughtUseCase>(
      () => MarkItemBoughtUseCase(repository: _getIt<ItemsRepository>()),
    );

    //! Recipe
    _getIt.registerFactory<ParseRecipeFromUrlUseCase>(
      () => ParseRecipeFromUrlUseCase(repository: _getIt<RecipeRepository>()),
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
    //! Brief feature
    _getIt.registerLazySingleton<BriefStore>(() => BriefStore());

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

    //! Lists
    _getIt.registerLazySingleton<ListsRemote>(
      () => ListsRemoteImpl(apiClient: _getIt<ApiClient>()),
    );
    _getIt.registerLazySingleton<ListsRepository>(
      () => ListsService(listsRemote: _getIt<ListsRemote>()),
    );

    //! Recipe
    _getIt.registerLazySingleton<RecipeScraper>(() => HttpRecipeScraper());
    _getIt.registerLazySingleton<RecipeRepository>(
      () => RecipeService(scraper: _getIt<RecipeScraper>()),
    );

    //! Items
    _getIt.registerLazySingleton<ItemsRemote>(
      () => ItemsRemoteImpl(apiClient: _getIt<ApiClient>()),
    );
    _getIt.registerLazySingleton<ItemsRepository>(
      () => ItemsService(remote: _getIt<ItemsRemote>()),
    );
    _getIt.registerLazySingleton<ItemDetailsPrefs>(
      () => ItemDetailsPrefs(db: _getIt<ILocalDB<dynamic>>()),
    );
    _getIt.registerLazySingleton<TutorialPrefs>(
      () => TutorialPrefs(_getIt<ILocalDB<dynamic>>()),
    );
  }
}
