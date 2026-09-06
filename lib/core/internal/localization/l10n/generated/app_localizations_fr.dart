// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Pora';

  @override
  String get language => 'Langue';

  @override
  String get authUnderAppName1 =>
      'Liste partagée pour les couples et les familles';

  @override
  String get authUnderAppName2 =>
      'Recettes, maison et livraison — tout au même endroit';

  @override
  String get onlyYou => 'Vous seulement';

  @override
  String get authSignInExpansibleExpand => 'Se connecter autrement';

  @override
  String get authSignInExpansibleCollapse => 'Réduire';

  @override
  String get sendAgainAfter => 'Renvoyer dans...';

  @override
  String get authSignInWithEmail => 'Se connecter avec un e-mail';

  @override
  String get authSignInWithGoogle => 'Se connecter avec Google';

  @override
  String get authSignInWithApple => 'Se connecter avec Apple';

  @override
  String get authSignInWithPhone => 'Se connecter avec un numéro de téléphone';

  @override
  String get authPrivatePolicy =>
      'By continuing, vous agree à le\\nTerms et Privacy Policy';

  @override
  String get authTitle => 'Presque terminé';

  @override
  String get authSubtitle =>
      'Saisissez votre téléphone number ou e-mail — we\'ll send vous a sign-dans code.';

  @override
  String get authSubtitle2 =>
      'Start typing — we\'ll detect whether it\'s a téléphone number ou e-mail.';

  @override
  String get authJoinButton => 'Rejoindre';

  @override
  String get userCreateProfileNameRequired => 'How about telling us votre nom?';

  @override
  String get commonError => 'Erreur';

  @override
  String get authErrorInvalidPhone => 'Invalid téléphone / e-mail!';

  @override
  String authPhoneSendOtp(String isPhone) {
    String _temp0 = intl.Intl.selectLogic(isPhone, {
      'true': 'Telegram!',
      'false': 'email!',
      'other': 'destination you wrote',
    });
    return 'We\'ll send code onto $_temp0';
  }

  @override
  String get otpTitle => 'Presque terminé !';

  @override
  String get otpEnterCodeSentTo => 'Saisissez le code envoyé à ';

  @override
  String get otpResendQuestion => 'Didn\'t receive le code?';

  @override
  String get otpResend => 'Renvoyer';

  @override
  String get otpVerifyButton => 'Vérifier le code';

  @override
  String get otpValidationLength => 'Saisissez le 6-digit code';

  @override
  String get otpValidationDigits => 'le code contains digits only';

  @override
  String get authSwitchToEmail => 'Se connecter avec un e-mail';

  @override
  String get authSwitchToPhone => 'Se connecter avec un numéro de téléphone';

  @override
  String onboardingStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get onboardingSlide1Title => 'recette → liste\\nin seconds';

  @override
  String get onboardingSlide1Body =>
      'Drop a recette link — Pora collects le ingrédients et removes what vous déjà avez.';

  @override
  String get onboardingSlide2Title => 'un liste\\nfor deux';

  @override
  String get onboardingSlide2Body =>
      'Add things together — vous peut see who ajouté what. Votre partner peut pick up what vous need sur le way home.';

  @override
  String get onboardingSlide3Title => 'Pora sait\nquand c’est le moment';

  @override
  String get onboardingSlide3Body =>
      'Based sur votre purchases, Pora predicts what sera run out bientôt et lets vous commande it avec un appuyez.';

  @override
  String get onboardingSkip => 'Ignorer';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get splashTagline => 'le liste that remembers pour vous';

  @override
  String get briefTitle => 'What do vous often run out of?';

  @override
  String get briefDeletionTitle =>
      'sont vous sure vous want à supprimer ce produit?';

  @override
  String get briefAddYourOwn => 'Ajouter';

  @override
  String get briefInputProduct => 'Saisissez a produit ou category';

  @override
  String get briefInputEmoji => 'Saisissez an emoji/icon pour le produit';

  @override
  String get briefAlreadyContains => 'ce produit est déjà sélectionné';

  @override
  String get briefSubtitle =>
      'sélectionner produits — Pora sera remind vous at le right time. Vous peut skip ce.';

  @override
  String get briefSkip => 'Ignorer';

  @override
  String get briefNext => 'Suivant';

  @override
  String get briefItemMilk => 'Lait';

  @override
  String get briefItemBread => 'Pain';

  @override
  String get briefItemEggs => 'Œufs';

  @override
  String get briefItemCoffee => 'Café';

  @override
  String get briefItemCheese => 'fromage';

  @override
  String get briefItemBananas => 'bananes';

  @override
  String get briefItemButter => 'beurre';

  @override
  String get briefItemWater => 'eau';

  @override
  String get briefItemVegetables => 'légumes';

  @override
  String get briefItemTomatoes => 'tomates';

  @override
  String get briefItemPasta => 'Pâtes';

  @override
  String get briefItemChicken => 'poulet';

  @override
  String get listTitle => 'Notre liste';

  @override
  String get listMembersCount => '2 personnes · 8 produits';

  @override
  String get listUrgent => 'Urgent';

  @override
  String get listAdd => 'Ajouter';

  @override
  String get predictionsTitle => 'Pora peut help!';

  @override
  String get predictionsSubtitle =>
      'Running out bientôt — based sur votre purchases';

  @override
  String get predictionTip => 'Une petite astuce';

  @override
  String get predictionsOrderTitle => 'commande everything avec un appuyez';

  @override
  String get predictionsOrderSubtitle => 'Samokat · livraison dans 15 minutes';

  @override
  String get predictionsOrderDiscount => '15% off votre first commande';

  @override
  String get predictionsAddToList => 'Add à liste';

  @override
  String get predictionsDismiss => 'non thanks';

  @override
  String get itemDetailName => 'Lait';

  @override
  String get itemDetailSubtitle => '2 L · Produits laitiers';

  @override
  String get itemDetailAddedBy => 'ajouté by';

  @override
  String get itemDetailSection => 'Section';

  @override
  String get itemDetailSectionValue => 'Produits laitiers';

  @override
  String get itemDetailQuantity => 'quantité';

  @override
  String get itemDetailQuantityValue => '2 L';

  @override
  String get itemDetailUrgent => 'Urgent';

  @override
  String get itemDetailRemind => 'Me rappeler';

  @override
  String get itemDetailRemindEvery => 'Every 7 jours';

  @override
  String get itemDetailInsight =>
      'Vous buy it about every 7 jours · last bought 6 jours ago. I\'ll suggest restocking bientôt.';

  @override
  String get itemDetailMarkBought => 'Marquer comme acheté';

  @override
  String get itemDetailDelete => 'retirer de liste';

  @override
  String get addItemTitle => 'Add produit';

  @override
  String get addItemExampleValue => 'Avocat';

  @override
  String get addItemNameHint => 'produit nom';

  @override
  String get addItemQuantity => 'quantité';

  @override
  String get addItemSection => 'Section';

  @override
  String get addItemUrgent => 'Urgent';

  @override
  String get addItemUrgentSubtitle => 'Need à buy aujourd’hui';

  @override
  String get addItemRemind => 'Rappeler régulièrement';

  @override
  String get addItemRemindEvery => 'Every 7 jours';

  @override
  String get addItemSubmit => 'Add à liste';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsHouseholdSection => 'Foyer';

  @override
  String get settingsAppSection => 'Application';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDelivery => 'Livraison';

  @override
  String get settingsProAd => 'Pora+ · ad-gratuit';

  @override
  String get settingsTryPill => 'Essayer';

  @override
  String get settingsPrivacy => 'Confidentialité et données';

  @override
  String get settingsAboutPora => 'À propos de Pora';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsMembersNames => 'Boris et Anna';

  @override
  String get settingsInvitePill => 'Inviter';

  @override
  String get householdInviteTitle => 'Invite votre partner';

  @override
  String get householdCookTogether => 'Cuisiner ensemble';

  @override
  String get householdInviteDescription =>
      'Pora works better pour deux. Invite votre partner — votre liste et reminders sera be partagé.';

  @override
  String get householdShareLink => 'Partager le lien';

  @override
  String get householdShowQr => 'Afficher le code QR';

  @override
  String get householdConnectToFamily => 'Rejoindre une famille';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      'We detected an invite code, but vous peut enter it yourself if we got it wrong';

  @override
  String get householdGotInvited => 'Vous\'ve been invited à a famille';

  @override
  String get householdWriteCode => 'Saisissez invite code';

  @override
  String get householdDoLater => 'Je le ferai plus tard';

  @override
  String get householdCopyCode => 'Copié dans le presse-papiers !';

  @override
  String get householdInviteCodeLabel => 'Code d’invitation';

  @override
  String get householdCopyPill => 'Copier';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsReadAll => 'Tout lire';

  @override
  String get notificationsMilkTitle => 'Grab lait sur votre way home';

  @override
  String get notificationsMilkBody =>
      'C’est épuisé — Anna l’a indiqué il y a 10 minutes.';

  @override
  String get notificationsMilkTime => 'Il y a 5 minutes';

  @override
  String get notificationsCoffeeTitle => 'café est running out bientôt';

  @override
  String get notificationsCoffeeBody =>
      'Vous buy it about every 14 jours, 12 avez passed.';

  @override
  String get notificationsPartnerAddedTitle => 'Anna ajouté 2 produits';

  @override
  String get notificationsPartnerAddedBody =>
      'bananes et pain sont dans le partagé liste.';

  @override
  String get notificationsPartnerAddedTime => 'aujourd’hui, 9:12';

  @override
  String get notificationsPromoTitle => '15% off votre first Samokat commande';

  @override
  String get notificationsPromoBody => 'le promo est active pour 6 more jours.';

  @override
  String get notificationsPromoTime => 'Hier';

  @override
  String get notificationsOrderDeliveredTitle => 'commande delivered';

  @override
  String get notificationsOrderDeliveredBody => '8 produits · Samokat · ₽1,054';

  @override
  String get notificationsAddToListPill => '＋ Add à liste';

  @override
  String get userCreateProfileTitle => 'What\'s votre nom?';

  @override
  String get userCreateProfileSubtitle =>
      'Add a nom et photo — votre partner sera see them dans le partagé liste.';

  @override
  String get userCreateProfileNameHint => 'Votre nom';

  @override
  String get userCreateProfileSkip => 'Ignorer';

  @override
  String get userCreateProfileNext => 'Suivant';

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get searchHint => 'produit ou recette…';

  @override
  String get searchFilterAll => 'Tous';

  @override
  String get searchFilterVegetables => 'légumes';

  @override
  String get searchFilterDairy => 'Produits laitiers';

  @override
  String get searchFilterGrocery => 'Courses';

  @override
  String get searchFilterRecipes => 'Recettes';

  @override
  String get searchResults => 'Résultats';

  @override
  String get searchNothingFound => 'Aucun résultat';

  @override
  String get insightsTitle => 'Analyses';

  @override
  String get insightsTipKicker => '✨ ASTUCE PORA';

  @override
  String get insightsTipTitle => 'Vous love carbonara!';

  @override
  String get insightsTipBody =>
      'Similar flavor profile — try mac et fromage. Vous déjà regularly avez 4 of 6 ingrédients.';

  @override
  String get insightsTipAction => 'ouvrir recette →';

  @override
  String get insightsRunsOutMost => 'Épuisé le plus souvent';

  @override
  String get insightsFavoriteCuisines => 'Cuisines préférées';

  @override
  String get insightsCuisineItalian => 'Italienne';

  @override
  String get insightsCuisinePasta => 'Pâtes';

  @override
  String get insightsCuisineBreakfasts => 'Petits-déjeuners';

  @override
  String get insightsCuisineLight => 'Clair';

  @override
  String get orderTitle => 'Commande';

  @override
  String get orderCart => 'Panier';

  @override
  String get orderWhenToDeliver => 'Quand livrer';

  @override
  String orderCheckoutCta(String total) {
    return 'commande de Samokat · $total';
  }

  @override
  String get orderSummaryGoods => 'Articles';

  @override
  String get orderSummaryDiscount => '15 % de réduction';

  @override
  String get orderSummaryDelivery => 'Livraison';

  @override
  String get orderSummaryFree => 'Gratuit';

  @override
  String get orderSummaryTotal => 'Total';

  @override
  String get recipeImportTitle => 'recette de a link';

  @override
  String get recipePreviewTitle => 'Pasta Carbonara';

  @override
  String get recipePreviewMeta => 'eda.ru · 25 min · 2 portions';

  @override
  String get recipePreviewFound => '6 ingrédients found';

  @override
  String get recipeDedupBanner =>
      'Removed 2 duplicates à avoid duplicating items déjà sur votre liste';

  @override
  String get recipeIngredients => 'Ingrédients';

  @override
  String get recipeAddToListCta => 'Add 4 produits à liste';

  @override
  String get recipeParseButton => 'Analyser';

  @override
  String get navList => 'Liste';

  @override
  String get navPora => 'Pora';

  @override
  String get navOrder => 'Commande';

  @override
  String get navProfile => 'Profil';

  @override
  String get familiesTitle => 'Familles';

  @override
  String get familiesSubtitle => 'choisir a famille à ouvrir its liste';

  @override
  String get familiesCurrent => 'Actuelle';

  @override
  String get familiesCreateOrJoin => '＋ Create ou join';

  @override
  String get familiesCreateDialog => 'What should we call le famille?';

  @override
  String get tryToUpdate => 'Réessayer';

  @override
  String get checkOut => 'Vérifier';

  @override
  String get settingsMore => 'Avancé';

  @override
  String get listsYour => 'Votre liste personnelle';

  @override
  String get human => 'personnes';

  @override
  String get products => 'produits';

  @override
  String get lists => 'listes';

  @override
  String get update => 'Actualiser';

  @override
  String get connectionSuccess => 'Rejoint';

  @override
  String get familiesNoUrgent => 'Rien d’urgent';

  @override
  String get welcomeBackTitle => 'Bon retour !';

  @override
  String get welcomeBackSubtitle => 'un second, opening votre liste…';

  @override
  String get errorDuringLoading => 'Erreur lors du chargement';

  @override
  String get familyName => 'Nom de la famille';

  @override
  String get familiesCreate => 'Créer';

  @override
  String get familiesConnect => 'Rejoindre';

  @override
  String get showAll => 'Tout afficher';

  @override
  String get priorityLabel => 'Priorité';

  @override
  String get everyDay => 'Tous les jours';

  @override
  String get newList => 'Nouvelle liste';

  @override
  String get listNamePlaceholder => 'Nom de la liste';

  @override
  String get cancel => 'Annuler';

  @override
  String get quantityLabel => 'Qté';

  @override
  String get personal => 'Personnel';

  @override
  String get notify => 'Notifier';

  @override
  String get notifyEveryone => 'Tout le monde';

  @override
  String get notifyRecipients => 'À';

  @override
  String get notifyAddCustom => 'Ajouter un nom';

  @override
  String get notifyMessageLabel => 'Message';

  @override
  String notifyHint(String itemName) {
    return 'Prendre $itemName en urgence';
  }

  @override
  String get notifySend => 'Envoyer';

  @override
  String get notifySent => 'Notification envoyée';

  @override
  String get advancedSettings => 'Paramètres avancés';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSection => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get notificationsPermission => 'notifications permission';

  @override
  String get granted => 'Autorisé';

  @override
  String get denied => 'Refusé';

  @override
  String get notDetermined => 'Non demandé';

  @override
  String get requestPermission => 'Demander';

  @override
  String get confirmations => 'Confirmations';

  @override
  String get askBeforeDelete => 'Demander avant suppression';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get deleteItemTitle => 'supprimer item?';

  @override
  String get deleteItemBody => 'ce cannot be undone.';

  @override
  String get dontAskAgain => 'Ne plus demander';

  @override
  String get delete => 'Supprimer';

  @override
  String get returnToList => 'Return à liste';

  @override
  String get nooneToNotify => 'non un à notify';

  @override
  String get notFound => 'ne found';

  @override
  String get recipeEmptyHint => 'Paste a recette URL et appuyez “Parse”';

  @override
  String get recipeDupMark => 'déjà dans liste';

  @override
  String get done => 'Terminé';

  @override
  String get errorGeneric => 'Erreur';

  @override
  String get pushToken => 'Jeton push';

  @override
  String get resync => 'Synchroniser';

  @override
  String get tokenSynced => 'Jeton synchronisé';

  @override
  String get deleteListTitle => 'supprimer liste?';

  @override
  String deleteListBody(String listName) {
    return 'liste “$listName” et all its items sera be deleted. ce cannot be undone.';
  }

  @override
  String get membersScreenTitle => 'Membres';

  @override
  String get owner => 'Propriétaire';

  @override
  String get member => 'Membre';

  @override
  String get addProduct => 'Add produit';

  @override
  String get productName => 'Nom';

  @override
  String get section => 'Section';

  @override
  String get unit => 'Unité';

  @override
  String get priorityHigh => 'Élevée';

  @override
  String get priorityMed => 'Moyenne';

  @override
  String get priorityLow => 'Faible';

  @override
  String get urgent => 'Urgent';

  @override
  String get remindEvery => 'Rappeler tous les';

  @override
  String get days => 'j';

  @override
  String get customValue => 'Personnalisé…';

  @override
  String get save => 'Enregistrer';

  @override
  String addedByName(String name) {
    return 'ajouté by: $name';
  }

  @override
  String get splashLoadingSlow => 'Presque terminé…';

  @override
  String get splashLoadingVerySlow =>
      'Chargement en cours… vérification de la connexion';

  @override
  String get profileNameUpdate => 'Mise à jour du profil';

  @override
  String get briefSnackBar => 'Maybe vous forgot à sélectionner any produits?';

  @override
  String get noInternet => 'non internet connection';

  @override
  String get noInternetButLoadYouLocally =>
      'non internet connection, but we sera load vous locally';

  @override
  String get groupDeletionTitle => 'sont vous sure want à supprimer groupe?';

  @override
  String get retry => 'Réessayer';

  @override
  String get groupsTitle => 'Vos groupes';

  @override
  String get groupsSubtitle =>
      'A liste est a groupe. Invite personnes — they\'ll see le liste.';

  @override
  String get groupCreate => 'Créer un groupe';

  @override
  String get groupConnect => 'Rejoindre';

  @override
  String get groupNameHint => 'Nom du groupe';

  @override
  String get groupPersonal => 'Personnel';

  @override
  String get groupShared => 'Partagé';

  @override
  String get noGroups => 'Aucun groupe pour le moment';

  @override
  String get settingsChangeThemeIOSEasterEgg =>
      '* à change votre thème, go à paramètres > PORA > thème\n* sélectionner a new thème de le paramètres menu\n* appuyez sur \'thème\' dans le app\'s paramètres à switch between clair et sombre modes';

  @override
  String get tutorialTitle => 'Comment ça marche';

  @override
  String get tutorialSkip => 'Ignorer';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialDone => 'Commencer';

  @override
  String get tutorialInviteTitle => 'Invite votre personnes';

  @override
  String get tutorialInviteBody =>
      'faites glisser a groupe right → Invite. Votre partner sees le same liste.';

  @override
  String get tutorialAddTitle => 'Add a produit';

  @override
  String get tutorialAddBody =>
      'appuyez + at le bottom of le liste. nom, qty, section, priority — done.';

  @override
  String get tutorialEditTitle => 'Edit et check off';

  @override
  String get tutorialEditBody =>
      'appuyez le checkbox — bought. appuyez le row — details et edits.';

  @override
  String get tutorialDeleteTitle => 'Supprimer';

  @override
  String get tutorialDeleteBody =>
      'faites glisser a produit left → supprimer. Confirmation peut be turned off.';

  @override
  String get tutorialAiTitle => 'Import a recette';

  @override
  String get tutorialAiBody =>
      'Paste a recette URL, appuyez Parse. ingrédients drop into le liste, duplicates marked.';

  @override
  String get tutorialSettingsTitle => 'Everything dans reach';

  @override
  String get tutorialSettingsBody =>
      'thème, language, notifications, confirmations — Profile → Advanced paramètres.';

  @override
  String get showTutorial => 'Afficher le tutoriel';

  @override
  String get tutorialSampleGroupFamily => 'Famille';

  @override
  String get tutorialSampleMilk => 'Lait';

  @override
  String get tutorialSampleBread => 'Pain';

  @override
  String get tutorialSampleAvocado => 'Avocat';

  @override
  String get tutorialSampleMilkQty => 'lait 2×1L';

  @override
  String get tutorialSampleCoffee => 'Café';

  @override
  String get tutorialSampleCola => 'Cola';

  @override
  String get tutorialSampleRecipeUrl => 'recipe.example/pasta';

  @override
  String get tutorialSampleIngredient1 => 'Spaghetti 400 g';

  @override
  String get tutorialSampleIngredient2 => 'tomates 500 g';

  @override
  String get tutorialSampleIngredient3 => 'Garlic 3 cloves';

  @override
  String get tutorialSampleToggleTheme => 'Thème';

  @override
  String get tutorialSampleToggleNotif => 'Notifications';

  @override
  String get tutorialSampleToggleConfirm => 'Confirmation';

  @override
  String get tutorialConnectTitle => 'Rejoindre avec un code';

  @override
  String get tutorialConnectBody =>
      'Partner sends a link ou code. Paste it — vous\'re dans le partagé liste.';

  @override
  String get tutorialNotifyTitle => 'Ping «need it now»';

  @override
  String get tutorialNotifyBody =>
      'appuyez «!» sur a produit — votre partner gets a push «buy it now». non calls needed.';

  @override
  String get tutorialOutroTitle => 'Vous\'ll figure out le rest';

  @override
  String get tutorialOutroBody =>
      'appuyez, faites glisser, mess up — le app forgives almost anything.';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => 'Anna';

  @override
  String get tutorialSamplePushBody => 'Need lait, urgent';

  @override
  String get tutorialSampleInviteMessage => 'Join le liste';

  @override
  String get supportMessage => 'e-mail assistance';

  @override
  String get supportMessageBottomSheetTopDescription =>
      'Votre message sera be envoyé à le assistance team. Please provide as much detail as possible.';

  @override
  String get supportMessageBottomSheetSendButton => 'Envoyer';

  @override
  String get supportMessageBottomSheetUnderButtonText =>
      'We sera answer as bientôt as possible, et mail à votre gmail ou inapp!';

  @override
  String get allergen => 'Allergène';

  @override
  String get predictionsGreeting => 'Votre jour avec PORA';

  @override
  String get predictionsGreetingSub => 'Smart hints de votre purchases';

  @override
  String get predictionsSectionSoon => 'Running out bientôt';

  @override
  String get predictionsSectionOften => 'Vous buy often';

  @override
  String get predictionsSectionAiSuggests => 'L’IA suggère';

  @override
  String get predictionsAiSuggestionsTitle => 'produits et recettes pour vous';

  @override
  String get predictionsAiSuggestionsTopic => 'votre preferences et purchases';

  @override
  String get refresh => 'Actualiser';

  @override
  String get predictionsOftenEmpty => 'ne enough data yet';

  @override
  String get predictionsAskPora => 'Demander à PORA';

  @override
  String get kpiWeek => 'items per semaine';

  @override
  String get kpiRecipes => 'recettes ce mois';

  @override
  String get kpiDaysToRun => 'jours until restock';

  @override
  String get fallbackTip1 =>
      'conserver herbs like a bouquet: dans a glass of eau covered avec a bag — lasts 2 weeks.';

  @override
  String get fallbackTip2 => 'Add sel à dough at le end — it slows down yeast.';

  @override
  String get fallbackTip3 =>
      'à stop onions stinging, chill them pour 15 minutes dans le freezer avant cutting.';

  @override
  String get fallbackTip4 =>
      'Oversalted soup? A raw potato pour 10 minutes soaks up le extra sel.';

  @override
  String get fallbackTip5 =>
      'Check egg freshness dans eau: sinks — frais, floats — discard.';

  @override
  String get fallbackTip6 =>
      'Reheat pizza dans a covered skillet — le crust crisps back up.';

  @override
  String get fallbackTip7 =>
      'congelé meat slices thinner — 20 minutes dans le freezer avant cutting.';

  @override
  String get fallbackTip8 =>
      'Roll a lemon sur le counter avant cutting — vous\'ll get more juice.';

  @override
  String get fallbackTip9 =>
      'A pinch of sucre dans tomato sauce cuts le acidity.';

  @override
  String get fallbackTip10 =>
      'pain keeps a mois dans le freezer; toasting it goes straight de congelé.';

  @override
  String get aiTipOfDayLabel => 'TIP OF le jour';

  @override
  String get aiTipOfDayTopic => 'aujourd’hui';

  @override
  String get aiCtaTitle => 'Demander à PORA';

  @override
  String get aiCtaSubtitle => 'recettes · swaps · tips';

  @override
  String get chatSheetTitle => 'PORA';

  @override
  String get chatSheetSubtitle =>
      'poser des questions sur la cuisine, les courses et les substitutions';

  @override
  String get chatEmptyTitle => 'Commencer une conversation';

  @override
  String get chatEmptyExamplesLabel => 'Exemples de questions :';

  @override
  String get chatSample1 => 'Que puis-je cook avec poulet et riz?';

  @override
  String get chatSample2 => 'What peut remplacer sour cream dans dough?';

  @override
  String get chatSample3 => 'Comment conserver herbs so they don\'t wilt?';

  @override
  String get chatSample4 => 'rapide 20-minute dîner recette';

  @override
  String get chatSample5 => 'Comment puis-je use up légumes avant they spoil?';

  @override
  String get chatSample6 => 'Créez une shopping liste pour 3 facile breakfasts';

  @override
  String get chatSample7 => 'Que dois-je cook pour deux avec a petit budget?';

  @override
  String get chatSample8 => 'How long peut I garder cuit riz dans le fridge?';

  @override
  String get chatSample9 => 'Donnez-moi a élevé-protein végétarien dîner';

  @override
  String get chatSample10 => 'What peut remplacer beurre dans ce recette?';

  @override
  String get chatSample11 => 'Planifiez trois dinners de what I déjà avez';

  @override
  String get chatSample12 => 'Que puis-je cook avec restes dans 15 minutes?';

  @override
  String get chatSample13 =>
      'Suggérez une adaptée aux allergies recette de my liste';

  @override
  String get chatSample14 => 'Comment puis-je make ce meal moins cher?';

  @override
  String get chatTyping => 'PORA est typing…';

  @override
  String get chatInputHint => 'Demandez n’importe quoi…';

  @override
  String get aiModelBadge => 'Powered by OpenRouter · ling-3.0-flash';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get tipTopicHerbs => 'herbes';

  @override
  String get tipTopicBaking => 'pâtisserie';

  @override
  String get tipTopicSoups => 'soupes';

  @override
  String get tipTopicMeat => 'viande';

  @override
  String get tipTopicFish => 'poisson';

  @override
  String get tipTopicVegetables => 'légumes';

  @override
  String get tipTopicStorage => 'conservation des aliments';

  @override
  String get tipTopicKitchenHacks => 'astuces de cuisine';

  @override
  String get tipTopicSpices => 'épices';

  @override
  String get tipTopicDough => 'pâte';

  @override
  String get tipTopicBreakfast => 'petits-déjeuners';

  @override
  String get tipTopicDinner => 'dîners';

  @override
  String get tipTopicsSectionTitle => 'Thèmes des astuces';

  @override
  String get tipTopicsSectionDescription =>
      'Pick which topics le tip est drawn de';

  @override
  String get tipTopicsAddCustom => 'Add votre own topic';

  @override
  String get tipTopicsCustomLabel => 'Personnalisé';

  @override
  String get tipTopicsPredefinedLabel => 'Prédéfini';

  @override
  String get tipTopicsEmpty => 'non topics sélectionné — tip sera be generic';

  @override
  String get insightsChampionKicker => 'CHAMPION OF le mois';

  @override
  String insightsChampionSubtitle(int count) {
    return 'bought $count fois ce mois';
  }

  @override
  String insightsStreakDays(int days) {
    return '$days jours dans a row';
  }

  @override
  String get insightsStreakSubtitle => 'vous\'re sur it — garder going';

  @override
  String insightsFreqEvery(int days) {
    return '~tous les $days j';
  }

  @override
  String get insightsPopular => 'Vous buy often';

  @override
  String get insightsStatsProducts => 'produits';

  @override
  String get insightsStatsLoginsWeek => 'logins ce semaine';

  @override
  String get insightsEmpty => 'non data yet — start adding produits';

  @override
  String get notificationsFilterAll => 'Tous';

  @override
  String get notificationsFilterUrgent => 'Urgent';

  @override
  String get notificationsFilterPrediction => 'Prévisions';

  @override
  String get notificationsFilterPromo => 'Promotion';

  @override
  String get notificationsFilterOther => 'Autre';

  @override
  String get notificationsClearAll => 'Tout effacer';

  @override
  String get notificationsDelete => 'Supprimer';

  @override
  String get notificationsGroupToday => 'Aujourd’hui';

  @override
  String get notificationsGroupYesterday => 'Hier';

  @override
  String get notificationsEmptyTitle => 'Tout est calme';

  @override
  String get notificationsEmptyBody => 'New notifications sera appear here';

  @override
  String get recipeCreateListCta => 'Où ajouter cette recette ?';

  @override
  String get recipeDupForceMark => 'sera quand même ajouté';

  @override
  String recipeDedupBannerMany(int n) {
    return '$n duplicates sera be skipped — uncheck à force-add';
  }

  @override
  String get offlineWriteBlocked => 'non internet — change won\'t be saved';

  @override
  String get offlineReadBanner => 'Hors ligne — affichage des données en cache';

  @override
  String get chatImportRecipeCta => 'Importer une recette';

  @override
  String get listsEmptyTitle => 'Vous n’avez encore aucune liste';

  @override
  String get listsEmptySubtitle =>
      'Vous devriez peut-être en créer une nouvelle ?';
}
