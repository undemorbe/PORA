// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get language => 'Sprache';

  @override
  String get onlyYou => 'Nur du';

  @override
  String get sendAgainAfter => 'Erneut senden in ...';

  @override
  String get authPrivatePolicy =>
      'Wenn du fortfährst, stimmst du den\nNutzungsbedingungen und der Datenschutzerklärung zu';

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
  String get onboardingSlide1Title => 'Rezept → Liste\nin Sekunden';

  @override
  String get onboardingSlide1Body =>
      'Füge einen Rezeptlink ein — Pora sammelt die Zutaten und entfernt, was du bereits hast.';

  @override
  String get onboardingSlide2Title => 'Eine Liste\nfür zwei';

  @override
  String get onboardingSlide2Body =>
      'Fügt Dinge gemeinsam hinzu — du siehst, wer was hinzugefügt hat. Dein Partner kann auf dem Heimweg mitbringen, was ihr braucht.';

  @override
  String get onboardingSlide3Title => 'Pora weiß,\nwann es Zeit ist';

  @override
  String get onboardingSlide3Body =>
      'Auf Basis deiner Einkäufe sagt Pora voraus, was bald ausgeht, und erinnert dich, es auf die Liste zu setzen.';

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
  String get listUrgent => 'Dringend';

  @override
  String get listAdd => 'Hinzufügen';

  @override
  String get predictionsAddToList => 'Füge hinzu zu Liste';

  @override
  String get predictionsDismiss => 'Nein, danke';

  @override
  String get itemDetailAddedBy => 'Hinzugefügt von';

  @override
  String get itemDetailQuantity => 'Menge';

  @override
  String get itemDetailUrgent => 'Dringend';

  @override
  String get itemDetailRemind => 'Mich erinnern';

  @override
  String get itemDetailMarkBought => 'Als gekauft markieren';

  @override
  String get itemDetailDelete => 'Aus Liste entfernen';

  @override
  String get addItemQuantity => 'Menge';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsPrivacy => 'Datenschutz und Daten';

  @override
  String get settingsAboutPora => 'Über Pora';

  @override
  String get settingsLogout => 'Abmelden';

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
  String get searchHint => 'Produkt oder Rezept …';

  @override
  String get searchNothingFound => 'Nichts gefunden';

  @override
  String get insightsTitle => 'Einblicke';

  @override
  String get recipeImportTitle => 'Rezept von a link';

  @override
  String get recipeIngredients => 'Zutaten';

  @override
  String recipeAddToListCta(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Produkt zur Liste hinzufügen';
  }

  @override
  String get recipeParseButton => 'Analysieren';

  @override
  String get navList => 'Liste';

  @override
  String get navPora => 'Pora';

  @override
  String get navProfile => 'Profil';

  @override
  String get familiesTitle => 'Familien';

  @override
  String get familiesSubtitle => 'Wähle eine Familie, um ihre Liste zu öffnen';

  @override
  String get familiesCreateDialog => 'What should we call der Familie?';

  @override
  String get tryToUpdate => 'Erneut versuchen';

  @override
  String get listsYour => 'Deine persönliche Liste';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '$count Person',
    );
    return '$_temp0';
  }

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '$count Produkt',
    );
    return '$_temp0';
  }

  @override
  String listsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Listen',
      one: '$count Liste',
    );
    return '$_temp0';
  }

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
  String get predictionsSectionAiSuggests => 'KI schlägt vor';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get kpiWeek => 'Produkte';

  @override
  String get kpiRecipes => 'oft gekauft';

  @override
  String get kpiDaysToRun => 'gehen zur Neige';

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
  String get insightsChampionKicker => 'DEIN TOP-PRODUKT';

  @override
  String insightsChampionSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal gekauft',
      one: 'einmal gekauft',
    );
    return '$_temp0';
  }

  @override
  String insightsStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage in Folge',
      one: '$days Tag in Folge',
    );
    return '$_temp0';
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
  String get offlineWriteBlocked =>
      'Kein Internet — die Änderung wird nicht gespeichert';

  @override
  String get offlineSavedQueued =>
      'Gespeichert. Wird gesendet, sobald du wieder online bist';

  @override
  String offlineSyncDropped(int count) {
    return 'Änderungen nicht synchronisiert: $count';
  }

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

  @override
  String get aiModelSettingsSection => 'Pora-AI-Modell';

  @override
  String get aiConfigRow => 'Eigenes Pora-AI-Modell';

  @override
  String get aiConfigRowSubtitle => 'Eigener OpenRouter-Schlüssel und Modelle';

  @override
  String get aiConfigTitle => 'Pora-AI-Modell';

  @override
  String get aiConfigIntro =>
      'Verbinden Sie Ihren eigenen OpenRouter-API-Schlüssel und wählen Sie die Modelle für Pora-AI. Lassen Sie ein Feld leer, um den Standard der App zu verwenden.';

  @override
  String get aiConfigApiKeyLabel => 'OpenRouter-API-Schlüssel';

  @override
  String get aiConfigApiKeyHint => 'sk-or-...';

  @override
  String get aiConfigModelsSection => 'Modelle';

  @override
  String get aiConfigPoraModelLabel => 'PORA-AI-Modell';

  @override
  String get aiConfigPoraModelHint => 'z. B. openai/gpt-4o-mini';

  @override
  String get aiConfigTipsModelLabel => 'Tipps-Modell';

  @override
  String get aiConfigTipsModelHint => 'Leer — wie App-Standard';

  @override
  String get aiConfigNeedKeyNote =>
      'Geben Sie Ihren API-Schlüssel ein, um eigene Modelle zu wählen';

  @override
  String get aiConfigReset => 'Auf Standard zurücksetzen';

  @override
  String get aiConfigSaved => 'Pora-AI-Einstellungen gespeichert';

  @override
  String get aiConfigResetDone => 'Pora-AI-Standard wiederhergestellt';

  @override
  String get aiConfigInfoTitle => 'So verbinden Sie Ihr Modell';

  @override
  String get aiConfigInfoBody =>
      '1. Erstellen Sie ein kostenloses Konto auf openrouter.ai.\n2. Öffnen Sie Keys, erstellen Sie einen neuen API-Schlüssel und fügen Sie ihn hier ein.\n3. Kopieren Sie unter openrouter.ai/models eine Modell-ID (zum Beispiel openai/gpt-4o-mini oder anthropic/claude-3.5-sonnet).\n4. Fügen Sie die ID in das Feld PORA-AI ein. Das Feld Tipps ist optional — leer lassen, um das Standardmodell der App mit Ihrem Schlüssel zu nutzen.\n\nIhr Schlüssel wird nur auf diesem Gerät gespeichert und nur für Ihre Pora-AI-Anfragen verwendet.';

  @override
  String get aiConfigInfoClose => 'Verstanden';

  @override
  String get supportEmptyError => 'Bitte zuerst eine Nachricht schreiben';

  @override
  String get supportSent => 'Nachricht gesendet — wir melden uns bald';

  @override
  String get supportFailed =>
      'Senden fehlgeschlagen. Verbindung prüfen und erneut versuchen';

  @override
  String get supportSheetHint =>
      'Beschreiben Sie Ihr Anliegen oder Feedback...';

  @override
  String get shortcutAddItem => 'Artikel hinzufügen';

  @override
  String importantReminderTitle(String product) {
    return '$product kaufen';
  }

  @override
  String importantReminderFrom(String user) {
    return 'von $user';
  }

  @override
  String get importantReminderBody => 'Als gekauft markieren, wenn erledigt';

  @override
  String get importantReminderMarkBought => 'Gekauft';

  @override
  String get liveActivityTestRow => 'Live Activity testen';

  @override
  String get liveActivityTestSample => 'Milch';

  @override
  String get listPickerTitle => 'Zu welcher Liste hinzufügen?';

  @override
  String get listPickerEmpty => 'Noch keine Listen — zuerst eine erstellen';

  @override
  String get predictionsAdded => 'Zur Liste hinzugefügt';

  @override
  String get shortcutOpenLists => 'Listen öffnen';

  @override
  String get shortcutOpenPora => 'Pora-AI fragen';

  @override
  String insightsPeriodDays(int days) {
    return '$days T.';
  }

  @override
  String insightsStreakBest(int days) {
    return 'Rekord: $days';
  }

  @override
  String get insightsStreakStart =>
      'Öffne Pora täglich, um eine Serie aufzubauen';

  @override
  String get insightsKpiAdded => 'hinzugefügt';

  @override
  String get insightsKpiBought => 'gekauft';

  @override
  String get insightsKpiCompletion => 'des Hinzugefügten gekauft';

  @override
  String get insightsKpiActiveDays => 'aktive Tage';

  @override
  String get insightsKpiMinutes => 'Minuten in der App';

  @override
  String get insightsKpiSessions => 'Sitzungen';

  @override
  String insightsAvgSession(String minutes) {
    return '≈$minutes Min. pro Sitzung';
  }

  @override
  String get insightsActivityTitle => 'Hinzugefügt und gekauft';

  @override
  String get insightsActivityEmpty => 'In diesem Zeitraum noch keine Aktivität';

  @override
  String get insightsHeatmapTitle => 'Aktivität · letzte 4 Wochen';

  @override
  String get insightsLess => 'weniger';

  @override
  String get insightsMore => 'mehr';

  @override
  String get insightsRhythmTitle => 'Dein Rhythmus';

  @override
  String get insightsPartMorning => 'Morgen';

  @override
  String get insightsPartAfternoon => 'Mittag';

  @override
  String get insightsPartEvening => 'Abend';

  @override
  String get insightsPartNight => 'Nacht';

  @override
  String get insightsPeakMorning => 'Am aktivsten bist du morgens';

  @override
  String get insightsPeakAfternoon => 'Am aktivsten bist du mittags';

  @override
  String get insightsPeakEvening => 'Am aktivsten bist du abends';

  @override
  String get insightsPeakNight => 'Am aktivsten bist du nachts';

  @override
  String insightsPeakWeekday(String day) {
    return 'Aktivster Tag — $day';
  }

  @override
  String get insightsCategoriesTitle => 'Was du hinzufügst';

  @override
  String get insightsDueSoonTitle => 'Zeit nachzukaufen';

  @override
  String get insightsDueNow => 'jetzt';

  @override
  String insightsDueInDays(int days) {
    return 'in ~$days T.';
  }

  @override
  String get insightsTopBoughtTitle => 'Im Zeitraum am häufigsten gekauft';

  @override
  String get insightsEngagementTitle => 'So nutzt du Pora';

  @override
  String get insightsKpiListsOpened => 'Listen geöffnet';

  @override
  String get insightsKpiListsCreated => 'Listen erstellt';

  @override
  String get insightsKpiRecipes => 'Rezepte importiert';

  @override
  String get insightsKpiAi => 'Nachrichten an Pora';

  @override
  String get insightsKpiDeleted => 'Artikel gelöscht';

  @override
  String get insightsAllTimeTitle => 'Insgesamt';

  @override
  String get insightsKpiReminders => 'mit Erinnerung';

  @override
  String get insightsKpiUrgent => 'dringend';

  @override
  String get insightsLocalNote =>
      'Nutzungsstatistiken werden auf deinem Gerät berechnet';

  @override
  String get insightsNoUsageYet =>
      'Statistiken erscheinen, sobald du Pora nutzt';

  @override
  String get settingsDeleteAccount => 'Konto löschen';

  @override
  String get deleteAccountTitle => 'Konto löschen?';

  @override
  String get deleteAccountBody =>
      'Dein Profil, deine persönlichen Listen und Nutzungsdaten werden dauerhaft gelöscht. Gemeinsame Familienlisten bleiben bei der Familie; gehört dir eine Familie, geht sie an das am längsten dabei befindliche Mitglied über. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAccountFailed =>
      'Konto konnte nicht gelöscht werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get chatReportAi => 'Melden';

  @override
  String get chatReportSent => 'Danke – wir prüfen diese Antwort.';

  @override
  String get chatReportFailed =>
      'Meldung konnte nicht gesendet werden. Versuche es später erneut.';

  @override
  String get aiDisclaimer =>
      'Pora AI kann Fehler machen. Prüfe wichtige Informationen.';

  @override
  String get groupLeave => 'Verlassen';

  @override
  String get groupLeaveTitle =>
      'Gruppe verlassen? Die Liste bleibt bei den anderen Mitgliedern.';

  @override
  String get groupDeleteOwnerOnly => 'Nur der Gruppeninhaber kann sie löschen';

  @override
  String get groupDeleteFailed =>
      'Gruppe konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get groupLeaveFailed =>
      'Gruppe konnte nicht verlassen werden. Bitte erneut versuchen.';

  @override
  String get listNoProductsTitle => 'Noch keine Produkte';

  @override
  String get listNoProductsSubtitle =>
      'Tippe auf „Hinzufügen“, um das erste Produkt auf die Liste zu setzen';

  @override
  String get unitPcs => 'Stk.';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitPack => 'Pkg.';

  @override
  String get sectionProduce => 'Obst & Gemüse';

  @override
  String get sectionDairy => 'Milchprodukte';

  @override
  String get sectionPantry => 'Vorräte';

  @override
  String get sectionDrinks => 'Getränke';

  @override
  String get sectionBread => 'Brot';

  @override
  String get sectionMisc => 'Verschiedenes';

  @override
  String get sectionOther => 'Sonstiges';
}
