// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get language => 'Langue';

  @override
  String get onlyYou => 'Vous seulement';

  @override
  String get sendAgainAfter => 'Renvoyer dans...';

  @override
  String get authPrivatePolicy =>
      'En continuant, vous acceptez les\nConditions d’utilisation et la Politique de confidentialité';

  @override
  String get authTitle => 'Presque terminé';

  @override
  String get authSubtitle =>
      'Saisissez votre numéro de téléphone ou votre e-mail — nous vous enverrons un code de connexion.';

  @override
  String get authSubtitle2 =>
      'Commencez à taper — nous détecterons s’il s’agit d’un numéro de téléphone ou d’un e-mail.';

  @override
  String get authJoinButton => 'Rejoindre';

  @override
  String get userCreateProfileNameRequired =>
      'Et si vous nous disiez votre prénom ?';

  @override
  String get commonError => 'Erreur';

  @override
  String get authErrorInvalidPhone => 'Téléphone ou e-mail invalide !';

  @override
  String authPhoneSendOtp(String isPhone) {
    String _temp0 = intl.Intl.selectLogic(isPhone, {
      'true': 'sur Telegram !',
      'false': 'par e-mail !',
      'other': 'à l’adresse indiquée',
    });
    return 'Nous enverrons le code $_temp0';
  }

  @override
  String get otpTitle => 'Presque terminé !';

  @override
  String get otpEnterCodeSentTo => 'Saisissez le code envoyé à ';

  @override
  String get otpResendQuestion => 'Vous n’avez pas reçu le code ?';

  @override
  String get otpResend => 'Renvoyer';

  @override
  String get otpVerifyButton => 'Vérifier le code';

  @override
  String get otpValidationLength => 'Saisissez le code à 6 chiffres';

  @override
  String get otpValidationDigits => 'Le code ne contient que des chiffres';

  @override
  String get authSwitchToEmail => 'Se connecter avec un e-mail';

  @override
  String get authSwitchToPhone => 'Se connecter avec un numéro de téléphone';

  @override
  String onboardingStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get onboardingSlide1Title => 'Recette → liste\nen quelques secondes';

  @override
  String get onboardingSlide1Body =>
      'Déposez le lien d’une recette — Pora rassemble les ingrédients et retire ce que vous avez déjà.';

  @override
  String get onboardingSlide2Title => 'Une liste\npour deux';

  @override
  String get onboardingSlide2Body =>
      'Ajoutez des articles ensemble — vous voyez qui a ajouté quoi. Votre partenaire peut acheter ce qu’il vous faut en rentrant.';

  @override
  String get onboardingSlide3Title => 'Pora sait\nquand c’est le moment';

  @override
  String get onboardingSlide3Body =>
      'D’après vos achats, Pora prévoit ce qui va bientôt manquer et vous rappelle de l’ajouter à votre liste.';

  @override
  String get onboardingSkip => 'Ignorer';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get splashTagline => 'La liste qui se souvient pour vous';

  @override
  String get briefTitle => 'Qu’est-ce qui vous manque souvent ?';

  @override
  String get briefDeletionTitle =>
      'Voulez-vous vraiment supprimer ce produit ?';

  @override
  String get briefAddYourOwn => 'Ajouter';

  @override
  String get briefInputProduct => 'Saisissez un produit ou une catégorie';

  @override
  String get briefInputEmoji =>
      'Saisissez un emoji ou une icône pour le produit';

  @override
  String get briefAlreadyContains => 'Ce produit est déjà sélectionné';

  @override
  String get briefSubtitle =>
      'Sélectionnez des produits — Pora vous les rappellera au bon moment. Vous pouvez passer cette étape.';

  @override
  String get briefSkip => 'Ignorer';

  @override
  String get briefNext => 'Suivant';

  @override
  String get listUrgent => 'Urgent';

  @override
  String get listAdd => 'Ajouter';

  @override
  String get predictionsAddToList => 'Ajouter à la liste';

  @override
  String get predictionsDismiss => 'Non merci';

  @override
  String get itemDetailAddedBy => 'Ajouté par';

  @override
  String get itemDetailQuantity => 'Quantité';

  @override
  String get itemDetailUrgent => 'Urgent';

  @override
  String get itemDetailRemind => 'Me rappeler';

  @override
  String get itemDetailMarkBought => 'Marquer comme acheté';

  @override
  String get itemDetailDelete => 'Retirer de la liste';

  @override
  String get addItemQuantity => 'Quantité';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppSection => 'Application';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Confidentialité et données';

  @override
  String get settingsAboutPora => 'À propos de Pora';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsInvitePill => 'Inviter';

  @override
  String get householdInviteTitle => 'Invitez votre partenaire';

  @override
  String get householdCookTogether => 'Cuisiner ensemble';

  @override
  String get householdInviteDescription =>
      'Pora fonctionne mieux à deux. Invitez votre partenaire — votre liste et vos rappels seront partagés.';

  @override
  String get householdShareLink => 'Partager le lien';

  @override
  String get householdShowQr => 'Afficher le code QR';

  @override
  String get householdConnectToFamily => 'Rejoindre une famille';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      'Nous avons détecté un code d’invitation, mais vous pouvez le saisir vous-même si nous nous sommes trompés';

  @override
  String get householdGotInvited =>
      'Vous avez été invité à rejoindre une famille';

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
  String get notificationsAddToListPill => '＋ Ajouter à la liste';

  @override
  String get userCreateProfileTitle => 'Comment vous appelez-vous ?';

  @override
  String get userCreateProfileSubtitle =>
      'Ajoutez un nom et une photo — votre partenaire les verra dans la liste partagée.';

  @override
  String get userCreateProfileNameHint => 'Votre nom';

  @override
  String get userCreateProfileSkip => 'Ignorer';

  @override
  String get userCreateProfileNext => 'Suivant';

  @override
  String get searchHint => 'Produit ou recette…';

  @override
  String get searchNothingFound => 'Aucun résultat';

  @override
  String get insightsTitle => 'Analyses';

  @override
  String get recipeImportTitle => 'Recette depuis un lien';

  @override
  String get recipeIngredients => 'Ingrédients';

  @override
  String recipeAddToListCta(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Ajouter $countString produit(s) à la liste';
  }

  @override
  String get recipeParseButton => 'Analyser';

  @override
  String get navList => 'Liste';

  @override
  String get navPora => 'Pora';

  @override
  String get navProfile => 'Profil';

  @override
  String get familiesTitle => 'Familles';

  @override
  String get familiesSubtitle => 'Choisissez une famille pour ouvrir sa liste';

  @override
  String get familiesCreateDialog => 'Comment appeler la famille ?';

  @override
  String get tryToUpdate => 'Réessayer';

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
  String get welcomeBackSubtitle => 'Un instant, ouverture de votre liste…';

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
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get notificationsPermission => 'Autorisation des notifications';

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
  String get deleteItemTitle => 'Supprimer l’article ?';

  @override
  String get deleteItemBody => 'Cette action est irréversible.';

  @override
  String get dontAskAgain => 'Ne plus demander';

  @override
  String get delete => 'Supprimer';

  @override
  String get returnToList => 'Retour à la liste';

  @override
  String get nooneToNotify => 'Personne à notifier';

  @override
  String get notFound => 'Introuvable';

  @override
  String get recipeEmptyHint =>
      'Collez l’URL d’une recette et appuyez sur « Analyser »';

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
  String get deleteListTitle => 'Supprimer la liste ?';

  @override
  String deleteListBody(String listName) {
    return 'La liste « $listName » et tous ses articles seront supprimés. Cette action est irréversible.';
  }

  @override
  String get membersScreenTitle => 'Membres';

  @override
  String get owner => 'Propriétaire';

  @override
  String get member => 'Membre';

  @override
  String get addProduct => 'Ajouter un produit';

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
    return 'Ajouté par : $name';
  }

  @override
  String get splashLoadingSlow => 'Presque terminé…';

  @override
  String get splashLoadingVerySlow =>
      'Chargement en cours… vérification de la connexion';

  @override
  String get profileNameUpdate => 'Mise à jour du profil';

  @override
  String get briefSnackBar =>
      'Vous avez peut-être oublié de sélectionner des produits ?';

  @override
  String get noInternet => 'Pas de connexion Internet';

  @override
  String get noInternetButLoadYouLocally =>
      'Pas de connexion Internet, nous chargeons vos données locales';

  @override
  String get groupDeletionTitle => 'Voulez-vous vraiment supprimer le groupe ?';

  @override
  String get retry => 'Réessayer';

  @override
  String get groupsTitle => 'Vos groupes';

  @override
  String get groupsSubtitle =>
      'Une liste est un groupe. Invitez des personnes — elles verront la liste.';

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
  String get tutorialTitle => 'Comment ça marche';

  @override
  String get tutorialSkip => 'Ignorer';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialDone => 'Commencer';

  @override
  String get tutorialInviteTitle => 'Invitez vos proches';

  @override
  String get tutorialInviteBody =>
      'Faites glisser un groupe vers la droite → Inviter. Votre partenaire voit la même liste.';

  @override
  String get tutorialAddTitle => 'Ajoutez un produit';

  @override
  String get tutorialAddBody =>
      'Appuyez sur + en bas de la liste. Nom, qté, section, priorité — c’est fait.';

  @override
  String get tutorialEditTitle => 'Modifiez et cochez';

  @override
  String get tutorialEditBody =>
      'Appuyez sur la case — c’est acheté. Appuyez sur la ligne — détails et modifications.';

  @override
  String get tutorialDeleteTitle => 'Supprimer';

  @override
  String get tutorialDeleteBody =>
      'Faites glisser un produit vers la gauche → Supprimer. La confirmation peut être désactivée.';

  @override
  String get tutorialAiTitle => 'Importez une recette';

  @override
  String get tutorialAiBody =>
      'Collez l’URL d’une recette, appuyez sur Analyser. Les ingrédients arrivent dans la liste, les doublons sont signalés.';

  @override
  String get tutorialSettingsTitle => 'Tout à portée de main';

  @override
  String get tutorialSettingsBody =>
      'Thème, langue, notifications, confirmations — Profil → Paramètres avancés.';

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
  String get tutorialSampleMilkQty => 'Lait 2×1 L';

  @override
  String get tutorialSampleCoffee => 'Café';

  @override
  String get tutorialSampleCola => 'Cola';

  @override
  String get tutorialSampleRecipeUrl => 'recipe.example/pasta';

  @override
  String get tutorialSampleIngredient1 => 'Spaghetti 400 g';

  @override
  String get tutorialSampleIngredient2 => 'Tomates 500 g';

  @override
  String get tutorialSampleIngredient3 => 'Ail 3 gousses';

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
      'Votre partenaire envoie un lien ou un code. Collez-le — vous voilà dans la liste partagée.';

  @override
  String get tutorialNotifyTitle => 'Alerte « il le faut maintenant »';

  @override
  String get tutorialNotifyBody =>
      'Appuyez sur « ! » sur un produit — votre partenaire reçoit une notification « à acheter tout de suite ». Pas besoin d’appeler.';

  @override
  String get tutorialOutroTitle => 'Vous découvrirez le reste';

  @override
  String get tutorialOutroBody =>
      'Appuyez, glissez, trompez-vous — l’app pardonne presque tout.';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => 'Anna';

  @override
  String get tutorialSamplePushBody => 'Il faut du lait, urgent';

  @override
  String get tutorialSampleInviteMessage => 'Rejoins la liste';

  @override
  String get supportMessage => 'Contacter l’assistance';

  @override
  String get supportMessageBottomSheetTopDescription =>
      'Votre message sera envoyé à l’équipe d’assistance. Merci de donner le plus de détails possible.';

  @override
  String get supportMessageBottomSheetSendButton => 'Envoyer';

  @override
  String get supportMessageBottomSheetUnderButtonText =>
      'Nous vous répondrons dès que possible, par e-mail ou dans l’application !';

  @override
  String get allergen => 'Allergène';

  @override
  String get predictionsGreeting => 'Votre journée avec PORA';

  @override
  String get predictionsGreetingSub =>
      'Des suggestions intelligentes d’après vos achats';

  @override
  String get predictionsSectionSoon => 'Bientôt épuisé';

  @override
  String get predictionsSectionAiSuggests => 'L’IA suggère';

  @override
  String get refresh => 'Actualiser';

  @override
  String get kpiWeek => 'produits';

  @override
  String get kpiRecipes => 'achats fréquents';

  @override
  String get kpiDaysToRun => 'bientôt épuisés';

  @override
  String get fallbackTip1 =>
      'Conservez les herbes comme un bouquet : dans un verre d’eau, couvertes d’un sachet — elles tiennent 2 semaines.';

  @override
  String get fallbackTip2 =>
      'Ajoutez le sel à la pâte en dernier — il ralentit la levure.';

  @override
  String get fallbackTip3 =>
      'Pour que les oignons ne piquent pas les yeux, placez-les 15 minutes au congélateur avant de les couper.';

  @override
  String get fallbackTip4 =>
      'Soupe trop salée ? Une pomme de terre crue plongée 10 minutes absorbe l’excès de sel.';

  @override
  String get fallbackTip5 =>
      'Testez la fraîcheur d’un œuf dans l’eau : il coule — frais, il flotte — à jeter.';

  @override
  String get fallbackTip6 =>
      'Réchauffez la pizza dans une poêle couverte — la pâte redevient croustillante.';

  @override
  String get fallbackTip7 =>
      'La viande congelée se tranche plus finement — 20 minutes au congélateur avant de la couper.';

  @override
  String get fallbackTip8 =>
      'Roulez le citron sur le plan de travail avant de le couper — vous obtiendrez plus de jus.';

  @override
  String get fallbackTip9 =>
      'Une pincée de sucre dans la sauce tomate atténue l’acidité.';

  @override
  String get fallbackTip10 =>
      'Le pain se garde un mois au congélateur ; on peut le griller directement sans le décongeler.';

  @override
  String get aiTipOfDayLabel => 'ASTUCE DU JOUR';

  @override
  String get aiTipOfDayTopic => 'aujourd’hui';

  @override
  String get aiCtaTitle => 'Demander à PORA';

  @override
  String get aiCtaSubtitle => 'recettes · substitutions · astuces';

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
  String get chatSample1 => 'Que puis-je cuisiner avec du poulet et du riz ?';

  @override
  String get chatSample2 =>
      'Par quoi remplacer la crème fraîche dans une pâte ?';

  @override
  String get chatSample3 =>
      'Comment conserver les herbes pour qu’elles ne fanent pas ?';

  @override
  String get chatSample4 => 'Recette de dîner rapide en 20 minutes';

  @override
  String get chatSample5 =>
      'Comment utiliser mes légumes avant qu’ils ne s’abîment ?';

  @override
  String get chatSample6 =>
      'Faites une liste de courses pour 3 petits-déjeuners simples';

  @override
  String get chatSample7 => 'Que cuisiner pour deux avec un petit budget ?';

  @override
  String get chatSample8 =>
      'Combien de temps garder du riz cuit au réfrigérateur ?';

  @override
  String get chatSample9 =>
      'Proposez-moi un dîner végétarien riche en protéines';

  @override
  String get chatSample10 =>
      'Par quoi remplacer le beurre dans cette recette ?';

  @override
  String get chatSample11 => 'Prévoyez trois dîners avec ce que j’ai déjà';

  @override
  String get chatSample12 => 'Que cuisiner avec des restes en 15 minutes ?';

  @override
  String get chatSample13 =>
      'Suggérez une recette sans allergènes à partir de ma liste';

  @override
  String get chatSample14 => 'Comment rendre ce plat moins cher ?';

  @override
  String get chatTyping => 'PORA écrit…';

  @override
  String get chatInputHint => 'Demandez n’importe quoi…';

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
      'Choisissez les thèmes dont l’astuce est tirée';

  @override
  String get tipTopicsAddCustom => 'Ajouter votre propre thème';

  @override
  String get tipTopicsCustomLabel => 'Personnalisé';

  @override
  String get tipTopicsPredefinedLabel => 'Prédéfini';

  @override
  String get tipTopicsEmpty =>
      'Aucun thème sélectionné — l’astuce sera générale';

  @override
  String get insightsChampionKicker => 'VOTRE PRODUIT N°1';

  @override
  String insightsChampionSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'acheté $count fois',
      one: 'acheté une fois',
    );
    return '$_temp0';
  }

  @override
  String insightsStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours d’affilée',
      one: '$days jour d’affilée',
    );
    return '$_temp0';
  }

  @override
  String get insightsStreakSubtitle => 'vous êtes lancé — continuez';

  @override
  String insightsFreqEvery(int days) {
    return '~tous les $days j';
  }

  @override
  String get insightsPopular => 'Vous achetez souvent';

  @override
  String get insightsStatsProducts => 'produits';

  @override
  String get insightsEmpty =>
      'Pas encore de données — commencez à ajouter des produits';

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
  String get notificationsEmptyBody =>
      'Les nouvelles notifications apparaîtront ici';

  @override
  String get recipeCreateListCta => 'Où ajouter cette recette ?';

  @override
  String get offlineWriteBlocked =>
      'Pas d’Internet — la modification ne sera pas enregistrée';

  @override
  String get offlineSavedQueued => 'Enregistré. Envoi dès le retour du réseau';

  @override
  String offlineSyncDropped(int count) {
    return 'Modifications non synchronisées : $count';
  }

  @override
  String get offlineReadBanner => 'Hors ligne — affichage des données en cache';

  @override
  String get chatImportRecipeCta => 'Importer une recette';

  @override
  String get listsEmptyTitle => 'Vous n’avez encore aucune liste';

  @override
  String get listsEmptySubtitle =>
      'Vous devriez peut-être en créer une nouvelle ?';

  @override
  String get aiModelSettingsSection => 'Modèle Pora-AI';

  @override
  String get aiConfigRow => 'Modèle Pora-AI personnalisé';

  @override
  String get aiConfigRowSubtitle => 'Votre clé OpenRouter et vos modèles';

  @override
  String get aiConfigTitle => 'Modèle Pora-AI';

  @override
  String get aiConfigIntro =>
      'Connectez votre propre clé API OpenRouter et choisissez les modèles de Pora-AI. Laissez un champ vide pour utiliser la valeur par défaut de l\'application.';

  @override
  String get aiConfigApiKeyLabel => 'Clé API OpenRouter';

  @override
  String get aiConfigApiKeyHint => 'sk-or-...';

  @override
  String get aiConfigModelsSection => 'Modèles';

  @override
  String get aiConfigPoraModelLabel => 'Modèle PORA-AI';

  @override
  String get aiConfigPoraModelHint => 'ex. openai/gpt-4o-mini';

  @override
  String get aiConfigTipsModelLabel => 'Modèle des conseils (Tips)';

  @override
  String get aiConfigTipsModelHint => 'Vide — comme par défaut';

  @override
  String get aiConfigNeedKeyNote =>
      'Saisissez votre clé API pour choisir des modèles';

  @override
  String get aiConfigReset => 'Réinitialiser par défaut';

  @override
  String get aiConfigSaved => 'Paramètres Pora-AI enregistrés';

  @override
  String get aiConfigResetDone => 'Paramètres Pora-AI par défaut restaurés';

  @override
  String get aiConfigInfoTitle => 'Comment connecter votre modèle';

  @override
  String get aiConfigInfoBody =>
      '1. Créez un compte gratuit sur openrouter.ai.\n2. Ouvrez Keys, créez une nouvelle clé API et collez-la ici.\n3. Sur openrouter.ai/models, copiez un identifiant de modèle (par exemple openai/gpt-4o-mini ou anthropic/claude-3.5-sonnet).\n4. Collez l\'identifiant dans le champ PORA-AI. Le champ Tips est facultatif — laissez-le vide pour réutiliser le modèle par défaut avec votre clé.\n\nVotre clé est stockée uniquement sur cet appareil et sert uniquement à vos requêtes Pora-AI.';

  @override
  String get aiConfigInfoClose => 'Compris';

  @override
  String get supportEmptyError => 'Veuillez d\'abord écrire un message';

  @override
  String get supportSent => 'Message envoyé — nous vous répondrons bientôt';

  @override
  String get supportFailed =>
      'Échec de l\'envoi. Vérifiez votre connexion et réessayez';

  @override
  String get supportSheetHint => 'Décrivez votre problème ou votre avis...';

  @override
  String get shortcutAddItem => 'Ajouter un article';

  @override
  String importantReminderTitle(String product) {
    return 'Acheter $product';
  }

  @override
  String importantReminderFrom(String user) {
    return 'de $user';
  }

  @override
  String get importantReminderBody => 'Marquer comme acheté une fois fait';

  @override
  String get importantReminderMarkBought => 'Acheté';

  @override
  String get liveActivityTestRow => 'Tester Live Activity';

  @override
  String get liveActivityTestSample => 'Lait';

  @override
  String get listPickerTitle => 'Ajouter à quelle liste ?';

  @override
  String get listPickerEmpty => 'Aucune liste — créez-en une d\'abord';

  @override
  String get predictionsAdded => 'Ajouté à la liste';

  @override
  String get shortcutOpenLists => 'Ouvrir les listes';

  @override
  String get shortcutOpenPora => 'Demander à Pora-AI';

  @override
  String insightsPeriodDays(int days) {
    return '$days j';
  }

  @override
  String insightsStreakBest(int days) {
    return 'Record : $days';
  }

  @override
  String get insightsStreakStart =>
      'Ouvrez Pora chaque jour pour lancer une série';

  @override
  String get insightsKpiAdded => 'ajoutés';

  @override
  String get insightsKpiBought => 'achetés';

  @override
  String get insightsKpiCompletion => 'des ajouts achetés';

  @override
  String get insightsKpiActiveDays => 'jours actifs';

  @override
  String get insightsKpiMinutes => 'minutes dans l\'app';

  @override
  String get insightsKpiSessions => 'sessions';

  @override
  String insightsAvgSession(String minutes) {
    return '≈$minutes min par session';
  }

  @override
  String get insightsActivityTitle => 'Ajoutés et achetés';

  @override
  String get insightsActivityEmpty => 'Aucune activité sur cette période';

  @override
  String get insightsHeatmapTitle => 'Activité · 4 dernières semaines';

  @override
  String get insightsLess => 'moins';

  @override
  String get insightsMore => 'plus';

  @override
  String get insightsRhythmTitle => 'Votre rythme';

  @override
  String get insightsPartMorning => 'Matin';

  @override
  String get insightsPartAfternoon => 'Après-midi';

  @override
  String get insightsPartEvening => 'Soir';

  @override
  String get insightsPartNight => 'Nuit';

  @override
  String get insightsPeakMorning => 'Vous êtes surtout actif le matin';

  @override
  String get insightsPeakAfternoon => 'Vous êtes surtout actif l\'après-midi';

  @override
  String get insightsPeakEvening => 'Vous êtes surtout actif le soir';

  @override
  String get insightsPeakNight => 'Vous êtes surtout actif la nuit';

  @override
  String insightsPeakWeekday(String day) {
    return 'Jour le plus actif — $day';
  }

  @override
  String get insightsCategoriesTitle => 'Ce que vous ajoutez';

  @override
  String get insightsDueSoonTitle => 'À racheter bientôt';

  @override
  String get insightsDueNow => 'maintenant';

  @override
  String insightsDueInDays(int days) {
    return 'dans ~$days j';
  }

  @override
  String get insightsTopBoughtTitle => 'Les plus achetés sur la période';

  @override
  String get insightsEngagementTitle => 'Votre usage de Pora';

  @override
  String get insightsKpiListsOpened => 'listes ouvertes';

  @override
  String get insightsKpiListsCreated => 'listes créées';

  @override
  String get insightsKpiRecipes => 'recettes importées';

  @override
  String get insightsKpiAi => 'messages à Pora';

  @override
  String get insightsKpiDeleted => 'articles supprimés';

  @override
  String get insightsAllTimeTitle => 'Depuis le début';

  @override
  String get insightsKpiReminders => 'avec rappel';

  @override
  String get insightsKpiUrgent => 'urgents';

  @override
  String get insightsLocalNote =>
      'Les statistiques d\'usage sont calculées sur votre appareil';

  @override
  String get insightsNoUsageYet => 'Les stats apparaîtront au fil de l\'usage';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountBody =>
      'Votre profil, vos listes personnelles et vos données d’utilisation seront définitivement supprimés. Les listes familiales partagées restent à la famille ; si vous en êtes propriétaire, elle passe au membre le plus ancien. Cette action est irréversible.';

  @override
  String get deleteAccountFailed =>
      'Impossible de supprimer le compte. Vérifiez votre connexion et réessayez.';

  @override
  String get chatReportAi => 'Signaler';

  @override
  String get chatReportSent => 'Merci, nous allons examiner cette réponse.';

  @override
  String get chatReportFailed =>
      'Impossible d’envoyer le signalement. Réessayez plus tard.';

  @override
  String get aiDisclaimer =>
      'Pora AI peut se tromper. Vérifiez les informations importantes.';
}
