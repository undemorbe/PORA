// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Zeit';

  @override
  String get language => 'Sprache';

  @override
  String get authUnderAppName1 => 'Gemeinsame Liste für Paare und Familien';

  @override
  String get authUnderAppName2 =>
      'Rezepte, Haushalt und Lieferung — alles an einem Ort';

  @override
  String get onlyYou => 'Nur du';

  @override
  String get authSignInExpansibleExpand => 'Auf andere Weise anmelden';

  @override
  String get authSignInExpansibleCollapse => 'Einklappen';

  @override
  String get sendAgainAfter => 'Erneut senden in ...';

  @override
  String get authSignInWithEmail => 'Mit E-Mail anmelden';

  @override
  String get authSignInWithGoogle => 'Mit Google anmelden';

  @override
  String get authSignInWithApple => 'Mit Apple anmelden';

  @override
  String get authSignInWithPhone => 'Mit Telefonnummer anmelden';

  @override
  String get authPrivatePolicy =>
      'Wenn du fortfährst, stimmst du den\\nNutzungsbedingungen und der Datenschutzerklärung zu';

  @override
  String get authTitle => 'Fast geschafft';

  @override
  String get authSubtitle =>
      'Gib deine Telefonnummer oder E-Mail-Adresse ein — wir senden dir einen Anmeldecode.';

  @override
  String get authSubtitle2 =>
      'Beginne zu tippen — wir erkennen, ob es eine Telefonnummer oder E-Mail-Adresse ist.';

  @override
  String get authJoinButton => 'Beitreten';

  @override
  String get userCreateProfileNameRequired =>
      'Wie wäre es, wenn du uns deinen Namen verrätst?';

  @override
  String get commonError => 'Fehler';

  @override
  String get authErrorInvalidPhone =>
      'Ungültige Telefonnummer / E-Mail-Adresse!';

  @override
  String authPhoneSendOtp(String isPhone) {
    String _temp0 = intl.Intl.selectLogic(isPhone, {
      'true': 'Telegram!',
      'false': 'deine E-Mail!',
      'other': 'das von dir angegebene Ziel',
    });
    return 'Wir senden den Code an $_temp0';
  }

  @override
  String get otpTitle => 'Fast geschafft!';

  @override
  String get otpEnterCodeSentTo => 'Gib den gesendeten Code ein: ';

  @override
  String get otpResendQuestion => 'Code nicht erhalten?';

  @override
  String get otpResend => 'Erneut senden';

  @override
  String get otpVerifyButton => 'Code bestätigen';

  @override
  String get otpValidationLength => 'Gib den 6-stelligen Code ein';

  @override
  String get otpValidationDigits => 'Der Code darf nur Ziffern enthalten';

  @override
  String get authSwitchToEmail => 'Mit E-Mail anmelden';

  @override
  String get authSwitchToPhone => 'Mit Telefonnummer anmelden';

  @override
  String onboardingStep(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get onboardingSlide1Title => 'Rezept → Liste\\nin Sekunden';

  @override
  String get onboardingSlide1Body =>
      'Füge einen Rezeptlink ein — Pora sammelt die Zutaten und entfernt, was du bereits hast.';

  @override
  String get onboardingSlide2Title => 'Eine Liste\\nfür zwei';

  @override
  String get onboardingSlide2Body =>
      'Fügt Dinge gemeinsam hinzu — du siehst, wer was hinzugefügt hat. Dein Partner kann auf dem Heimweg mitbringen, was ihr braucht.';

  @override
  String get onboardingSlide3Title => 'Pora weiß,\\nwann es Zeit ist';

  @override
  String get onboardingSlide3Body =>
      'Auf Basis deiner Einkäufe sagt Pora voraus, was bald ausgeht, und du kannst es mit einem Tippen nachbestellen.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingStart => 'Starten';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get splashTagline => 'Die Liste, die für dich mitdenkt';

  @override
  String get briefTitle => 'Was geht dir häufig aus?';

  @override
  String get briefDeletionTitle =>
      'Möchtest du dieses Produkt wirklich löschen?';

  @override
  String get briefAddYourOwn => 'Hinzufügen';

  @override
  String get briefInputProduct => 'Produkt oder Kategorie eingeben';

  @override
  String get briefInputEmoji => 'Emoji/Symbol für das Produkt eingeben';

  @override
  String get briefAlreadyContains => 'Dieses Produkt ist bereits ausgewählt';

  @override
  String get briefSubtitle =>
      'Wähle Produkte aus — Pora erinnert dich zum richtigen Zeitpunkt. Du kannst diesen Schritt überspringen.';

  @override
  String get briefSkip => 'Überspringen';

  @override
  String get briefNext => 'Weiter';

  @override
  String get briefItemMilk => 'Milch';

  @override
  String get briefItemBread => 'Brot';

  @override
  String get briefItemEggs => 'Eier';

  @override
  String get briefItemCoffee => 'Kaffee';

  @override
  String get briefItemCheese => 'Käse';

  @override
  String get briefItemBananas => 'Bananen';

  @override
  String get briefItemButter => 'Butter';

  @override
  String get briefItemWater => 'Wasser';

  @override
  String get briefItemVegetables => 'Gemüse';

  @override
  String get briefItemTomatoes => 'Tomaten';

  @override
  String get briefItemPasta => 'Pasta';

  @override
  String get briefItemChicken => 'Hähnchen';

  @override
  String get listTitle => 'Unsere Liste';

  @override
  String get listMembersCount => '2 Personen · 8 Produkte';

  @override
  String get listUrgent => 'Dringend';

  @override
  String get listAdd => 'Hinzufügen';

  @override
  String get predictionsTitle => 'Pora kann helfen!';

  @override
  String get predictionsSubtitle =>
      'Geht bald aus — basierend auf deinen Einkäufen';

  @override
  String get predictionTip => 'Ein kleiner Tipp';

  @override
  String get predictionsOrderTitle => 'Alles mit einem Tippen bestellen';

  @override
  String get predictionsOrderSubtitle => 'Samokat · Lieferung in 15 Minuten';

  @override
  String get predictionsOrderDiscount =>
      '15 % Rabatt auf deine erste Bestellung';

  @override
  String get predictionsAddToList => 'Füge hinzu zu Liste';

  @override
  String get predictionsDismiss => 'Nein, danke';

  @override
  String get itemDetailName => 'Milch';

  @override
  String get itemDetailSubtitle => '2 l · Milchprodukte';

  @override
  String get itemDetailAddedBy => 'Hinzugefügt von';

  @override
  String get itemDetailSection => 'Bereich';

  @override
  String get itemDetailSectionValue => 'Milchprodukte';

  @override
  String get itemDetailQuantity => 'Menge';

  @override
  String get itemDetailQuantityValue => '2 L';

  @override
  String get itemDetailUrgent => 'Dringend';

  @override
  String get itemDetailRemind => 'Mich erinnern';

  @override
  String get itemDetailRemindEvery => 'Alle 7 Tage';

  @override
  String get itemDetailInsight =>
      'Du kaufst es etwa alle 7 Tage · zuletzt vor 6 Tagen gekauft. Ich schlage bald einen Nachkauf vor.';

  @override
  String get itemDetailMarkBought => 'Als gekauft markieren';

  @override
  String get itemDetailDelete => 'Aus Liste entfernen';

  @override
  String get addItemTitle => 'Produkt hinzufügen';

  @override
  String get addItemExampleValue => 'Avocado';

  @override
  String get addItemNameHint => 'Produktname';

  @override
  String get addItemQuantity => 'Menge';

  @override
  String get addItemSection => 'Bereich';

  @override
  String get addItemUrgent => 'Dringend';

  @override
  String get addItemUrgentSubtitle => 'Heute kaufen';

  @override
  String get addItemRemind => 'Regelmäßig erinnern';

  @override
  String get addItemRemindEvery => 'Alle 7 Tage';

  @override
  String get addItemSubmit => 'Füge hinzu zu Liste';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsHouseholdSection => 'Haushalt';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsDelivery => 'Lieferung';

  @override
  String get settingsProAd => 'Pora+ · ad-kostenlos';

  @override
  String get settingsTryPill => 'Ausprobieren';

  @override
  String get settingsPrivacy => 'Datenschutz und Daten';

  @override
  String get settingsAboutPora => 'Über Pora';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsMembersNames => 'Boris und Anna';

  @override
  String get settingsInvitePill => 'Einladen';

  @override
  String get householdInviteTitle => 'Invite deine partner';

  @override
  String get householdCookTogether => 'Gemeinsam kochen';

  @override
  String get householdInviteDescription =>
      'Pora funktioniert zu zweit besser. Lade deinen Partner ein — eure Liste und Erinnerungen werden geteilt.';

  @override
  String get householdShareLink => 'Link teilen';

  @override
  String get householdShowQr => 'QR-Code anzeigen';

  @override
  String get householdConnectToFamily => 'Familie beitreten';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      'Wir haben einen Einladungscode erkannt, aber du kannst ihn selbst eingeben, falls wir uns geirrt haben.';

  @override
  String get householdGotInvited => 'Du wurdest zu einer Familie eingeladen';

  @override
  String get householdWriteCode => 'Gib ein invite Code';

  @override
  String get householdDoLater => 'Ich mache es später';

  @override
  String get householdCopyCode => 'In die Zwischenablage kopiert!';

  @override
  String get householdInviteCodeLabel => 'Einladungscode';

  @override
  String get householdCopyPill => 'Kopieren';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsReadAll => 'Alle lesen';

  @override
  String get notificationsMilkTitle => 'Bring auf dem Heimweg Milch mit';

  @override
  String get notificationsMilkBody =>
      'Sie ist ausgegangen — Anna hat es vor 10 Minuten markiert.';

  @override
  String get notificationsMilkTime => '5 Minuten ago';

  @override
  String get notificationsCoffeeTitle => 'Der Kaffee geht bald aus';

  @override
  String get notificationsCoffeeBody =>
      'Du kaufst ihn etwa alle 14 Tage, 12 sind bereits vergangen.';

  @override
  String get notificationsPartnerAddedTitle =>
      'Anna hat 2 Produkte hinzugefügt';

  @override
  String get notificationsPartnerAddedBody =>
      'Bananen und Brot stehen auf der gemeinsamen Liste.';

  @override
  String get notificationsPartnerAddedTime => 'heute, 9:12';

  @override
  String get notificationsPromoTitle =>
      '15 % Rabatt auf deine erste Samokat-Bestellung';

  @override
  String get notificationsPromoBody => 'Die Aktion ist noch 6 Tage aktiv.';

  @override
  String get notificationsPromoTime => 'Gestern';

  @override
  String get notificationsOrderDeliveredTitle => 'Bestellung geliefert';

  @override
  String get notificationsOrderDeliveredBody => '8 Produkte · Samokat · ₽1.054';

  @override
  String get notificationsAddToListPill => '＋ Füge hinzu zu Liste';

  @override
  String get userCreateProfileTitle => 'What\'s deine Name?';

  @override
  String get userCreateProfileSubtitle =>
      'Füge einen Namen und ein Foto hinzu — dein Partner sieht beides in der gemeinsamen Liste.';

  @override
  String get userCreateProfileNameHint => 'Deine Name';

  @override
  String get userCreateProfileSkip => 'Überspringen';

  @override
  String get userCreateProfileNext => 'Weiter';

  @override
  String get searchTitle => 'Suchen';

  @override
  String get searchHint => 'Produkt oder Rezept …';

  @override
  String get searchFilterAll => 'Alle';

  @override
  String get searchFilterVegetables => 'Gemüse';

  @override
  String get searchFilterDairy => 'Milchprodukte';

  @override
  String get searchFilterGrocery => 'Lebensmittel';

  @override
  String get searchFilterRecipes => 'Rezepte';

  @override
  String get searchResults => 'Ergebnisse';

  @override
  String get searchNothingFound => 'Nichts gefunden';

  @override
  String get insightsTitle => 'Einblicke';

  @override
  String get insightsTipKicker => '✨ PORA-TIPP';

  @override
  String get insightsTipTitle => 'Du liebst Carbonara!';

  @override
  String get insightsTipBody =>
      'Ähnliches Geschmacksprofil — probiere Mac and Cheese. 4 von 6 Zutaten hast du bereits regelmäßig zu Hause.';

  @override
  String get insightsTipAction => 'Rezept öffnen →';

  @override
  String get insightsRunsOutMost => 'Geht am häufigsten aus';

  @override
  String get insightsFavoriteCuisines => 'Lieblingsküchen';

  @override
  String get insightsCuisineItalian => 'Italienisch';

  @override
  String get insightsCuisinePasta => 'Pasta';

  @override
  String get insightsCuisineBreakfasts => 'Frühstücke';

  @override
  String get insightsCuisineLight => 'Hell';

  @override
  String get orderTitle => 'Bestellung';

  @override
  String get orderCart => 'Warenkorb';

  @override
  String get orderWhenToDeliver => 'Wann liefern?';

  @override
  String orderCheckoutCta(String total) {
    return 'Bei Samokat bestellen · $total';
  }

  @override
  String get orderSummaryGoods => 'Artikel';

  @override
  String get orderSummaryDiscount => '15 % Rabatt';

  @override
  String get orderSummaryDelivery => 'Lieferung';

  @override
  String get orderSummaryFree => 'Kostenlos';

  @override
  String get orderSummaryTotal => 'Gesamt';

  @override
  String get recipeImportTitle => 'Rezept von a link';

  @override
  String get recipePreviewTitle => 'Pasta Carbonara';

  @override
  String get recipePreviewMeta => 'eda.ru · 25 Min. · 2 Portionen';

  @override
  String get recipePreviewFound => '6 Zutaten gefunden';

  @override
  String get recipeDedupBanner =>
      '2 Duplikate entfernt, damit bereits gelistete Artikel nicht doppelt hinzugefügt werden';

  @override
  String get recipeIngredients => 'Zutaten';

  @override
  String get recipeAddToListCta => '4 Produkte zur Liste hinzufügen';

  @override
  String get recipeParseButton => 'Analysieren';

  @override
  String get navList => 'Liste';

  @override
  String get navPora => 'Pora';

  @override
  String get navOrder => 'Bestellung';

  @override
  String get navProfile => 'Profil';

  @override
  String get familiesTitle => 'Familien';

  @override
  String get familiesSubtitle => 'Wähle eine Familie, um ihre Liste zu öffnen';

  @override
  String get familiesCurrent => 'Aktuell';

  @override
  String get familiesCreateOrJoin => '＋ Create oder join';

  @override
  String get familiesCreateDialog => 'What should we call der Familie?';

  @override
  String get tryToUpdate => 'Erneut versuchen';

  @override
  String get checkOut => 'Prüfen';

  @override
  String get settingsMore => 'Erweitert';

  @override
  String get listsYour => 'Deine persönliche Liste';

  @override
  String get human => 'Personen';

  @override
  String get products => 'Produkte';

  @override
  String get lists => 'Listen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get connectionSuccess => 'Beigetreten';

  @override
  String get familiesNoUrgent => 'Nichts Dringendes';

  @override
  String get welcomeBackTitle => 'Willkommen zurück!';

  @override
  String get welcomeBackSubtitle => 'Einen Moment, deine Liste wird geöffnet …';

  @override
  String get errorDuringLoading => 'Fehler beim Laden';

  @override
  String get familyName => 'Familienname';

  @override
  String get familiesCreate => 'Erstellen';

  @override
  String get familiesConnect => 'Beitreten';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get priorityLabel => 'Priorität';

  @override
  String get everyDay => 'Jeden Tag';

  @override
  String get newList => 'Neue Liste';

  @override
  String get listNamePlaceholder => 'Listenname';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get quantityLabel => 'Menge';

  @override
  String get personal => 'Persönlich';

  @override
  String get notify => 'Benachrichtigen';

  @override
  String get notifyEveryone => 'Alle';

  @override
  String get notifyRecipients => 'An';

  @override
  String get notifyAddCustom => 'Namen hinzufügen';

  @override
  String get notifyMessageLabel => 'Nachricht';

  @override
  String notifyHint(String itemName) {
    return '$itemName dringend besorgen';
  }

  @override
  String get notifySend => 'Senden';

  @override
  String get notifySent => 'Benachrichtigung gesendet';

  @override
  String get advancedSettings => 'Erweiterte Einstellungen';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeSection => 'Theme';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get notificationsPermission => 'Benachrichtigungen permission';

  @override
  String get granted => 'Erlaubt';

  @override
  String get denied => 'Abgelehnt';

  @override
  String get notDetermined => 'Nicht angefragt';

  @override
  String get requestPermission => 'Anfragen';

  @override
  String get confirmations => 'Bestätigungen';

  @override
  String get askBeforeDelete => 'Vor dem Löschen fragen';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get deleteItemTitle => 'Artikel löschen?';

  @override
  String get deleteItemBody => 'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get dontAskAgain => 'Nicht erneut fragen';

  @override
  String get delete => 'Löschen';

  @override
  String get returnToList => 'Zurück zur Liste';

  @override
  String get nooneToNotify => 'Niemand zu benachrichtigen';

  @override
  String get notFound => 'nicht found';

  @override
  String get recipeEmptyHint =>
      'Füge eine Rezept-URL ein und tippe auf „Analysieren“';

  @override
  String get recipeDupMark => 'bereits in der Liste';

  @override
  String get done => 'Fertig';

  @override
  String get errorGeneric => 'Fehler';

  @override
  String get pushToken => 'Push-Token';

  @override
  String get resync => 'Synchronisieren';

  @override
  String get tokenSynced => 'Token synchronisiert';

  @override
  String get deleteListTitle => 'löschen Liste?';

  @override
  String deleteListBody(String listName) {
    return 'Die Liste „$listName“ und alle darin enthaltenen Artikel werden gelöscht. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get membersScreenTitle => 'Mitglieder';

  @override
  String get owner => 'Besitzer';

  @override
  String get member => 'Mitglied';

  @override
  String get addProduct => 'Produkt hinzufügen';

  @override
  String get productName => 'Name';

  @override
  String get section => 'Bereich';

  @override
  String get unit => 'Einheit';

  @override
  String get priorityHigh => 'Hoch';

  @override
  String get priorityMed => 'Mittel';

  @override
  String get priorityLow => 'Niedrig';

  @override
  String get urgent => 'Dringend';

  @override
  String get remindEvery => 'Erinnern alle';

  @override
  String get days => 'd';

  @override
  String get customValue => 'Benutzerdefiniert …';

  @override
  String get save => 'Speichern';

  @override
  String addedByName(String name) {
    return 'Hinzugefügt von: $name';
  }

  @override
  String get splashLoadingSlow => 'Fast geschafft …';

  @override
  String get splashLoadingVerySlow =>
      'Wird noch geladen … Verbindung wird geprüft';

  @override
  String get profileNameUpdate => 'Profil wird aktualisiert';

  @override
  String get briefSnackBar =>
      'Vielleicht hast du vergessen, Produkte auszuwählen?';

  @override
  String get noInternet => 'Keine Internetverbindung';

  @override
  String get noInternetButLoadYouLocally =>
      'Keine Internetverbindung, aber wir laden deine Daten lokal.';

  @override
  String get groupDeletionTitle => 'Möchtest du die Gruppe wirklich löschen?';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get groupsTitle => 'Deine Gruppen';

  @override
  String get groupsSubtitle =>
      'Eine Liste ist eine Gruppe. Lade Personen ein — sie sehen die Liste.';

  @override
  String get groupCreate => 'Gruppe erstellen';

  @override
  String get groupConnect => 'Beitreten';

  @override
  String get groupNameHint => 'Gruppenname';

  @override
  String get groupPersonal => 'Persönlich';

  @override
  String get groupShared => 'Geteilt';

  @override
  String get noGroups => 'Noch keine Gruppen';

  @override
  String get settingsChangeThemeIOSEasterEgg =>
      '* Um das Theme zu ändern, gehe zu Einstellungen > PORA > Theme\n* Wähle ein neues Theme im Einstellungsmenü\n* Tippe in den App-Einstellungen auf „Theme“, um zwischen hellem und dunklem Modus zu wechseln';

  @override
  String get tutorialTitle => 'So funktioniert es';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get tutorialDone => 'Starten';

  @override
  String get tutorialInviteTitle => 'Lade deine Leute ein';

  @override
  String get tutorialInviteBody =>
      'Wische eine Gruppe nach rechts → Einladen. Dein Partner sieht dieselbe Liste.';

  @override
  String get tutorialAddTitle => 'Füge hinzu a Produkt';

  @override
  String get tutorialAddBody =>
      'Tippe unten in der Liste auf +. Name, Menge, Bereich, Priorität — fertig.';

  @override
  String get tutorialEditTitle => 'Edit und check off';

  @override
  String get tutorialEditBody =>
      'Tippe auf das Kontrollkästchen — gekauft. Tippe auf die Zeile — Details und Bearbeiten.';

  @override
  String get tutorialDeleteTitle => 'Löschen';

  @override
  String get tutorialDeleteBody =>
      'Wische ein Produkt nach links → Löschen. Die Bestätigung kann deaktiviert werden.';

  @override
  String get tutorialAiTitle => 'Import a Rezept';

  @override
  String get tutorialAiBody =>
      'Füge eine Rezept-URL ein und tippe auf Analysieren. Die Zutaten landen in der Liste, Duplikate werden markiert.';

  @override
  String get tutorialSettingsTitle => 'Alles griffbereit';

  @override
  String get tutorialSettingsBody =>
      'Theme, Sprache, Benachrichtigungen, Bestätigungen — Profil → Erweiterte Einstellungen.';

  @override
  String get showTutorial => 'Tutorial anzeigen';

  @override
  String get tutorialSampleGroupFamily => 'Familie';

  @override
  String get tutorialSampleMilk => 'Milch';

  @override
  String get tutorialSampleBread => 'Brot';

  @override
  String get tutorialSampleAvocado => 'Avocado';

  @override
  String get tutorialSampleMilkQty => 'Milch 2×1L';

  @override
  String get tutorialSampleCoffee => 'Kaffee';

  @override
  String get tutorialSampleCola => 'Cola';

  @override
  String get tutorialSampleRecipeUrl => 'recipe.example/pasta';

  @override
  String get tutorialSampleIngredient1 => 'Spaghetti 400 g';

  @override
  String get tutorialSampleIngredient2 => 'Tomaten 500 g';

  @override
  String get tutorialSampleIngredient3 => 'Garlic 3 cloves';

  @override
  String get tutorialSampleToggleTheme => 'Theme';

  @override
  String get tutorialSampleToggleNotif => 'Benachrichtigungen';

  @override
  String get tutorialSampleToggleConfirm => 'Bestätigung';

  @override
  String get tutorialConnectTitle => 'Join by Code';

  @override
  String get tutorialConnectBody =>
      'Dein Partner sendet einen Link oder Code. Füge ihn ein — du bist in der gemeinsamen Liste.';

  @override
  String get tutorialNotifyTitle => 'Ping «need it now»';

  @override
  String get tutorialNotifyBody =>
      'Tippe bei einem Produkt auf „!“ — dein Partner erhält eine Push-Nachricht „jetzt kaufen“. Keine Anrufe nötig.';

  @override
  String get tutorialOutroTitle => 'Den Rest findest du selbst heraus';

  @override
  String get tutorialOutroBody =>
      'Tippen, wischen, etwas falsch machen — die App verzeiht fast alles.';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => 'Anna';

  @override
  String get tutorialSamplePushBody => 'Milch nötig, dringend';

  @override
  String get tutorialSampleInviteMessage => 'Der Liste beitreten';

  @override
  String get supportMessage => 'E-Mail-Support';

  @override
  String get supportMessageBottomSheetTopDescription =>
      'Deine Nachricht wird an das Support-Team gesendet. Bitte gib so viele Details wie möglich an.';

  @override
  String get supportMessageBottomSheetSendButton => 'Senden';

  @override
  String get supportMessageBottomSheetUnderButtonText =>
      'Wir antworten so schnell wie möglich per Gmail oder direkt in der App!';

  @override
  String get allergen => 'Allergen';

  @override
  String get predictionsGreeting => 'Dein Tag mit PORA';

  @override
  String get predictionsGreetingSub =>
      'Intelligente Hinweise aus deinen Einkäufen';

  @override
  String get predictionsSectionSoon => 'Running out bald';

  @override
  String get predictionsSectionOften => 'Du kaufst häufig';

  @override
  String get predictionsSectionAiSuggests => 'KI schlägt vor';

  @override
  String get predictionsAiSuggestionsTitle => 'Produkte und Rezepte für dich';

  @override
  String get predictionsAiSuggestionsTopic => 'deine Vorlieben und Einkäufe';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get predictionsOftenEmpty => 'Noch nicht genug Daten';

  @override
  String get predictionsAskPora => 'PORA fragen';

  @override
  String get kpiWeek => 'Artikel pro Woche';

  @override
  String get kpiRecipes => 'Rezepte diesen Monat';

  @override
  String get kpiDaysToRun => 'Tage bis zum Nachkauf';

  @override
  String get fallbackTip1 =>
      'Bewahre Kräuter wie einen Blumenstrauß auf: in einem Glas Wasser und mit einem Beutel abgedeckt — hält 2 Wochen.';

  @override
  String get fallbackTip2 =>
      'Gib Salz erst am Ende zum Teig — das verlangsamt die Hefe.';

  @override
  String get fallbackTip3 =>
      'Damit Zwiebeln nicht in den Augen brennen, kühle sie vor dem Schneiden 15 Minuten im Gefrierfach.';

  @override
  String get fallbackTip4 =>
      'Suppe zu salzig? Eine rohe Kartoffel nimmt in 10 Minuten überschüssiges Salz auf.';

  @override
  String get fallbackTip5 =>
      'Prüfe die Frische eines Eis im Wasser: sinkt es, ist es frisch; schwimmt es, wegwerfen.';

  @override
  String get fallbackTip6 =>
      'Erwärme Pizza in einer abgedeckten Pfanne — der Boden wird wieder knusprig.';

  @override
  String get fallbackTip7 =>
      'Gefrorenes Fleisch lässt sich dünner schneiden — 20 Minuten vor dem Schneiden ins Gefrierfach.';

  @override
  String get fallbackTip8 =>
      'Rolle eine Zitrone vor dem Schneiden über die Arbeitsfläche — so bekommst du mehr Saft.';

  @override
  String get fallbackTip9 =>
      'Eine Prise Zucker in Tomatensauce mildert die Säure.';

  @override
  String get fallbackTip10 =>
      'Brot hält sich einen Monat im Gefrierfach; zum Toasten kann es direkt gefroren verwendet werden.';

  @override
  String get aiTipOfDayLabel => 'TIPP DES TAGES';

  @override
  String get aiTipOfDayTopic => 'heute';

  @override
  String get aiCtaTitle => 'PORA fragen';

  @override
  String get aiCtaSubtitle => 'Rezepte · Alternativen · Tipps';

  @override
  String get chatSheetTitle => 'PORA';

  @override
  String get chatSheetSubtitle =>
      'Fragen zu Essen, Einkäufen und Ersatzprodukten';

  @override
  String get chatEmptyTitle => 'Gespräch starten';

  @override
  String get chatEmptyExamplesLabel => 'Beispielfragen:';

  @override
  String get chatSample1 => 'Was kann ich mit Hähnchen und Reis kochen?';

  @override
  String get chatSample2 => 'Was kann saure Sahne im Teig ersetzen?';

  @override
  String get chatSample3 =>
      'Wie bewahre ich Kräuter auf, damit sie nicht welken?';

  @override
  String get chatSample4 => 'Schnelles 20-Minuten-Abendessen';

  @override
  String get chatSample5 =>
      'Wie kann ich Gemüse aufbrauchen, bevor es verdirbt?';

  @override
  String get chatSample6 =>
      'Erstelle eine Einkaufsliste für 3 einfache Frühstücke';

  @override
  String get chatSample7 =>
      'Was soll ich für zwei Personen mit kleinem Budget kochen?';

  @override
  String get chatSample8 =>
      'Wie lange kann ich gekochten Reis im Kühlschrank aufbewahren?';

  @override
  String get chatSample9 =>
      'Gib mir ein vegetarisches Abendessen mit viel Protein';

  @override
  String get chatSample10 => 'Was kann Butter in diesem Rezept ersetzen?';

  @override
  String get chatSample11 =>
      'Plane drei Abendessen aus dem, was ich bereits habe';

  @override
  String get chatSample12 => 'Was kann ich in 15 Minuten aus Resten kochen?';

  @override
  String get chatSample13 =>
      'Schlage ein allergikerfreundliches Rezept aus meiner Liste vor';

  @override
  String get chatSample14 => 'Wie kann ich dieses Gericht günstiger machen?';

  @override
  String get chatTyping => 'PORA schreibt …';

  @override
  String get chatInputHint => 'Frag alles …';

  @override
  String get aiModelBadge => 'Powered by OpenRouter · ling-3.0-flash';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get tipTopicHerbs => 'Kräuter';

  @override
  String get tipTopicBaking => 'Backen';

  @override
  String get tipTopicSoups => 'Suppen';

  @override
  String get tipTopicMeat => 'Fleisch';

  @override
  String get tipTopicFish => 'Fisch';

  @override
  String get tipTopicVegetables => 'Gemüse';

  @override
  String get tipTopicStorage => 'Lebensmittelaufbewahrung';

  @override
  String get tipTopicKitchenHacks => 'Küchentricks';

  @override
  String get tipTopicSpices => 'Gewürze';

  @override
  String get tipTopicDough => 'Teig';

  @override
  String get tipTopicBreakfast => 'Frühstücke';

  @override
  String get tipTopicDinner => 'Abendessen';

  @override
  String get tipTopicsSectionTitle => 'Tipp-Themen';

  @override
  String get tipTopicsSectionDescription =>
      'Wähle die Themen aus, aus denen der Tipp stammt';

  @override
  String get tipTopicsAddCustom => 'Eigenes Thema hinzufügen';

  @override
  String get tipTopicsCustomLabel => 'Benutzerdefiniert';

  @override
  String get tipTopicsPredefinedLabel => 'Vordefiniert';

  @override
  String get tipTopicsEmpty =>
      'Keine Themen ausgewählt — der Tipp wird allgemein sein';

  @override
  String get insightsChampionKicker => 'CHAMPION DES MONATS';

  @override
  String insightsChampionSubtitle(int count) {
    return 'diesen Monat $count-mal gekauft';
  }

  @override
  String insightsStreakDays(int days) {
    return '$days Tage in Folge';
  }

  @override
  String get insightsStreakSubtitle => 'Du bist dran — weiter so';

  @override
  String insightsFreqEvery(int days) {
    return '~alle $days Tage';
  }

  @override
  String get insightsPopular => 'Du kaufst häufig';

  @override
  String get insightsStatsProducts => 'Produkte';

  @override
  String get insightsStatsLoginsWeek => 'Anmeldungen diese Woche';

  @override
  String get insightsEmpty => 'Noch keine Daten — füge Produkte hinzu';

  @override
  String get notificationsFilterAll => 'Alle';

  @override
  String get notificationsFilterUrgent => 'Dringend';

  @override
  String get notificationsFilterPrediction => 'Prognosen';

  @override
  String get notificationsFilterPromo => 'Werbung';

  @override
  String get notificationsFilterOther => 'Andere';

  @override
  String get notificationsClearAll => 'Alle löschen';

  @override
  String get notificationsDelete => 'Löschen';

  @override
  String get notificationsGroupToday => 'Heute';

  @override
  String get notificationsGroupYesterday => 'Gestern';

  @override
  String get notificationsEmptyTitle => 'Alles ruhig';

  @override
  String get notificationsEmptyBody =>
      'New Benachrichtigungen wird appear here';

  @override
  String get recipeCreateListCta => 'Wo soll dieses Rezept hinzugefügt werden?';

  @override
  String get recipeDupForceMark => 'wird trotzdem hinzugefügt';

  @override
  String recipeDedupBannerMany(int n) {
    return '$n Duplikate werden übersprungen — deaktiviere die Auswahl, um sie trotzdem hinzuzufügen';
  }

  @override
  String get offlineWriteBlocked =>
      'Kein Internet — die Änderung wird nicht gespeichert';

  @override
  String get offlineReadBanner =>
      'Offline — zwischengespeicherte Daten werden angezeigt';

  @override
  String get chatImportRecipeCta => 'Rezept importieren';

  @override
  String get listsEmptyTitle => 'Sie haben noch keine Listen';

  @override
  String get listsEmptySubtitle =>
      'Vielleicht sollten Sie eine neue erstellen?';
}
