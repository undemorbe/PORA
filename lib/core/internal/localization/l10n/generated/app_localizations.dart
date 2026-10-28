import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// onlyYou
  ///
  /// In en, this message translates to:
  /// **'Only you'**
  String get onlyYou;

  /// The sign in with other methods title
  ///
  /// In en, this message translates to:
  /// **'Send again in...'**
  String get sendAgainAfter;

  /// The private policy link text
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the\nTerms and Privacy Policy'**
  String get authPrivatePolicy;

  /// authTitle
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get authTitle;

  /// authSubtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number or email — we\'ll send you a sign-in code.'**
  String get authSubtitle;

  /// authSubtitle2
  ///
  /// In en, this message translates to:
  /// **'Start typing — we\'ll detect whether it\'s a phone number or email.'**
  String get authSubtitle2;

  /// authJoinButton
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get authJoinButton;

  /// userCreateProfileNameRequired
  ///
  /// In en, this message translates to:
  /// **'How about telling us your name?'**
  String get userCreateProfileNameRequired;

  /// commonError
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// Invalid phone on auth screen
  ///
  /// In en, this message translates to:
  /// **'Invalid phone / email!'**
  String get authErrorInvalidPhone;

  /// Invalid phone on auth screen
  ///
  /// In en, this message translates to:
  /// **'We\'ll send code onto {isPhone, select, true{Telegram!} false{email!} other{destination you wrote}}'**
  String authPhoneSendOtp(String isPhone);

  /// otpTitle
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get otpTitle;

  /// otpEnterCodeSentTo
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to '**
  String get otpEnterCodeSentTo;

  /// otpResendQuestion
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpResendQuestion;

  /// otpResend
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get otpResend;

  /// otpVerifyButton
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get otpVerifyButton;

  /// otpValidationLength
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpValidationLength;

  /// otpValidationDigits
  ///
  /// In en, this message translates to:
  /// **'The code contains digits only'**
  String get otpValidationDigits;

  /// authSwitchToEmail
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get authSwitchToEmail;

  /// authSwitchToPhone
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone'**
  String get authSwitchToPhone;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(int step, int total);

  /// onboardingSlide1Title
  ///
  /// In en, this message translates to:
  /// **'Recipe → list\nin seconds'**
  String get onboardingSlide1Title;

  /// onboardingSlide1Body
  ///
  /// In en, this message translates to:
  /// **'Drop a recipe link — Pora collects the ingredients and removes what you already have.'**
  String get onboardingSlide1Body;

  /// onboardingSlide2Title
  ///
  /// In en, this message translates to:
  /// **'One list\nfor two'**
  String get onboardingSlide2Title;

  /// onboardingSlide2Body
  ///
  /// In en, this message translates to:
  /// **'Add things together — you can see who added what. Your partner can pick up what you need on the way home.'**
  String get onboardingSlide2Body;

  /// onboardingSlide3Title
  ///
  /// In en, this message translates to:
  /// **'Pora knows\nwhen it\'s time'**
  String get onboardingSlide3Title;

  /// onboardingSlide3Body
  ///
  /// In en, this message translates to:
  /// **'Based on your purchases, Pora predicts what will run out soon and reminds you to add it to your list.'**
  String get onboardingSlide3Body;

  /// onboardingSkip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// onboardingStart
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// onboardingNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// splashTagline
  ///
  /// In en, this message translates to:
  /// **'The list that remembers for you'**
  String get splashTagline;

  /// briefTitle
  ///
  /// In en, this message translates to:
  /// **'What do you often run out of?'**
  String get briefTitle;

  /// briefDeletionTitle
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get briefDeletionTitle;

  /// briefAddYourOwn
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get briefAddYourOwn;

  /// briefInputProduct
  ///
  /// In en, this message translates to:
  /// **'Enter a product or category'**
  String get briefInputProduct;

  /// briefInputEmoji
  ///
  /// In en, this message translates to:
  /// **'Enter an emoji/icon for the product'**
  String get briefInputEmoji;

  /// briefAlreadyContains
  ///
  /// In en, this message translates to:
  /// **'This product is already selected'**
  String get briefAlreadyContains;

  /// briefSubtitle
  ///
  /// In en, this message translates to:
  /// **'Select products — Pora will remind you at the right time. You can skip this.'**
  String get briefSubtitle;

  /// briefSkip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get briefSkip;

  /// briefNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get briefNext;

  /// listUrgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get listUrgent;

  /// listAdd
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get listAdd;

  /// predictionsAddToList
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get predictionsAddToList;

  /// predictionsDismiss
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get predictionsDismiss;

  /// itemDetailAddedBy
  ///
  /// In en, this message translates to:
  /// **'Added by'**
  String get itemDetailAddedBy;

  /// itemDetailQuantity
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get itemDetailQuantity;

  /// itemDetailUrgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get itemDetailUrgent;

  /// itemDetailRemind
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get itemDetailRemind;

  /// itemDetailMarkBought
  ///
  /// In en, this message translates to:
  /// **'Mark as bought'**
  String get itemDetailMarkBought;

  /// itemDetailDelete
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get itemDetailDelete;

  /// addItemQuantity
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get addItemQuantity;

  /// settingsTitle
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// settingsAppSection
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsAppSection;

  /// settingsNotifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// settingsPrivacy
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get settingsPrivacy;

  /// settingsAboutPora
  ///
  /// In en, this message translates to:
  /// **'About Pora'**
  String get settingsAboutPora;

  /// settingsLogout
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsLogout;

  /// settingsInvitePill
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get settingsInvitePill;

  /// householdInviteTitle
  ///
  /// In en, this message translates to:
  /// **'Invite your partner'**
  String get householdInviteTitle;

  /// householdCookTogether
  ///
  /// In en, this message translates to:
  /// **'Cook together'**
  String get householdCookTogether;

  /// householdInviteDescription
  ///
  /// In en, this message translates to:
  /// **'Pora works better for two. Invite your partner — your list and reminders will be shared.'**
  String get householdInviteDescription;

  /// householdShareLink
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get householdShareLink;

  /// householdShowQr
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get householdShowQr;

  /// householdConnectToFamily
  ///
  /// In en, this message translates to:
  /// **'Join a family'**
  String get householdConnectToFamily;

  /// householdInviteDescriptionWhenConnecting
  ///
  /// In en, this message translates to:
  /// **'We detected an invite code, but you can enter it yourself if we got it wrong'**
  String get householdInviteDescriptionWhenConnecting;

  /// householdGotInvited
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to a family'**
  String get householdGotInvited;

  /// householdDoLater
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it later'**
  String get householdDoLater;

  /// householdCopyCode
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get householdCopyCode;

  /// householdInviteCodeLabel
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get householdInviteCodeLabel;

  /// householdCopyPill
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get householdCopyPill;

  /// notificationsTitle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// notificationsReadAll
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get notificationsReadAll;

  /// notificationsAddToListPill
  ///
  /// In en, this message translates to:
  /// **'＋ Add to list'**
  String get notificationsAddToListPill;

  /// userCreateProfileTitle
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get userCreateProfileTitle;

  /// userCreateProfileSubtitle
  ///
  /// In en, this message translates to:
  /// **'Add a name and photo — your partner will see them in the shared list.'**
  String get userCreateProfileSubtitle;

  /// userCreateProfileNameHint
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get userCreateProfileNameHint;

  /// userCreateProfileSkip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get userCreateProfileSkip;

  /// userCreateProfileNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get userCreateProfileNext;

  /// searchHint
  ///
  /// In en, this message translates to:
  /// **'Product or recipe…'**
  String get searchHint;

  /// searchNothingFound
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNothingFound;

  /// insightsTitle
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// recipeImportTitle
  ///
  /// In en, this message translates to:
  /// **'Recipe from a link'**
  String get recipeImportTitle;

  /// recipeIngredients
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// Add the selected recipe products to the list
  ///
  /// In en, this message translates to:
  /// **'Add {count} product to list'**
  String recipeAddToListCta(int count);

  /// recipeParseButton
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get recipeParseButton;

  /// navList
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get navList;

  /// navPora
  ///
  /// In en, this message translates to:
  /// **'Pora'**
  String get navPora;

  /// navProfile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// familiesTitle
  ///
  /// In en, this message translates to:
  /// **'Families'**
  String get familiesTitle;

  /// familiesSubtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a family to open its list'**
  String get familiesSubtitle;

  /// familiesCreateDialog
  ///
  /// In en, this message translates to:
  /// **'What should we call the family?'**
  String get familiesCreateDialog;

  /// tryToUpdate
  ///
  /// In en, this message translates to:
  /// **'Try refreshing'**
  String get tryToUpdate;

  /// listsYour
  ///
  /// In en, this message translates to:
  /// **'Your personal list'**
  String get listsYour;

  /// Members count in the list header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} person} other{{count} people}}'**
  String peopleCount(int count);

  /// Products count in the list header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} product} other{{count} products}}'**
  String productsCount(int count);

  /// Lists count in the lists header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} list} other{{count} lists}}'**
  String listsCount(int count);

  /// update
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get update;

  /// connectionSuccess
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get connectionSuccess;

  /// familiesNoUrgent
  ///
  /// In en, this message translates to:
  /// **'Nothing urgent'**
  String get familiesNoUrgent;

  /// welcomeBackTitle
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBackTitle;

  /// welcomeBackSubtitle
  ///
  /// In en, this message translates to:
  /// **'One second, opening your list…'**
  String get welcomeBackSubtitle;

  /// errorDuringLoading
  ///
  /// In en, this message translates to:
  /// **'Error while loading'**
  String get errorDuringLoading;

  /// nameOfFamily
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyName;

  /// createButton
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get familiesCreate;

  /// connectButton
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get familiesConnect;

  /// showAll
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// priorityLabel
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// everyDay
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// newList
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newList;

  /// listNamePlaceholder
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNamePlaceholder;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// quantityLabel
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantityLabel;

  /// personal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// notify
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notify;

  /// notifyEveryone
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get notifyEveryone;

  /// notifyRecipients
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get notifyRecipients;

  /// notifyAddCustom
  ///
  /// In en, this message translates to:
  /// **'Add name'**
  String get notifyAddCustom;

  /// notifyMessageLabel
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notifyMessageLabel;

  /// notifyHint placeholder
  ///
  /// In en, this message translates to:
  /// **'Grab {itemName} urgently'**
  String notifyHint(String itemName);

  /// notifySend
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get notifySend;

  /// notifySent
  ///
  /// In en, this message translates to:
  /// **'Notification sent'**
  String get notifySent;

  /// advancedSettings
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get advancedSettings;

  /// appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// themeLight
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// themeDark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// themeSystem
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// notificationsPermission
  ///
  /// In en, this message translates to:
  /// **'Notifications permission'**
  String get notificationsPermission;

  /// granted
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// denied
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// notDetermined
  ///
  /// In en, this message translates to:
  /// **'Not requested'**
  String get notDetermined;

  /// requestPermission
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestPermission;

  /// confirmations
  ///
  /// In en, this message translates to:
  /// **'Confirmations'**
  String get confirmations;

  /// askBeforeDelete
  ///
  /// In en, this message translates to:
  /// **'Ask before deletion'**
  String get askBeforeDelete;

  /// about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// deleteItemTitle
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteItemTitle;

  /// deleteItemBody
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteItemBody;

  /// dontAskAgain
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get dontAskAgain;

  /// delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// returnToList
  ///
  /// In en, this message translates to:
  /// **'Return to list'**
  String get returnToList;

  /// nooneToNotify
  ///
  /// In en, this message translates to:
  /// **'No one to notify'**
  String get nooneToNotify;

  /// notFound
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// recipeEmptyHint
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe URL and tap “Parse”'**
  String get recipeEmptyHint;

  /// done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// errorGeneric
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorGeneric;

  /// pushToken
  ///
  /// In en, this message translates to:
  /// **'Push token'**
  String get pushToken;

  /// resync
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get resync;

  /// tokenSynced
  ///
  /// In en, this message translates to:
  /// **'Token synced'**
  String get tokenSynced;

  /// deleteListTitle
  ///
  /// In en, this message translates to:
  /// **'Delete list?'**
  String get deleteListTitle;

  /// deleteListBody placeholder
  ///
  /// In en, this message translates to:
  /// **'List “{listName}” and all its items will be deleted. This cannot be undone.'**
  String deleteListBody(String listName);

  /// membersScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersScreenTitle;

  /// owner
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// member
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// addProduct
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// productName
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productName;

  /// section
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// unit
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// priorityHigh
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// priorityMed
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMed;

  /// priorityLow
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// urgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// remindEvery
  ///
  /// In en, this message translates to:
  /// **'Remind every'**
  String get remindEvery;

  /// days
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get days;

  /// customValue
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get customValue;

  /// save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// addedByName placeholder
  ///
  /// In en, this message translates to:
  /// **'Added by: {name}'**
  String addedByName(String name);

  /// splashLoadingSlow
  ///
  /// In en, this message translates to:
  /// **'Almost there…'**
  String get splashLoadingSlow;

  /// splashLoadingVerySlow
  ///
  /// In en, this message translates to:
  /// **'Still loading… checking connection'**
  String get splashLoadingVerySlow;

  /// profileNameUpdate
  ///
  /// In en, this message translates to:
  /// **'Profile updating'**
  String get profileNameUpdate;

  /// briefSnackBar
  ///
  /// In en, this message translates to:
  /// **'Maybe you forgot to select any products?'**
  String get briefSnackBar;

  /// noInternet
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// noInternetButLoadYouLocally
  ///
  /// In en, this message translates to:
  /// **'No internet connection, but we will load you locally'**
  String get noInternetButLoadYouLocally;

  /// groupDeletionTitle
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to delete group?'**
  String get groupDeletionTitle;

  /// retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// groupsTitle
  ///
  /// In en, this message translates to:
  /// **'Your groups'**
  String get groupsTitle;

  /// groupsSubtitle
  ///
  /// In en, this message translates to:
  /// **'A list is a group. Invite people — they\'ll see the list.'**
  String get groupsSubtitle;

  /// groupCreate
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupCreate;

  /// groupConnect
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get groupConnect;

  /// groupNameHint
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameHint;

  /// groupPersonal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get groupPersonal;

  /// groupShared
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get groupShared;

  /// tutorialTitle
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get tutorialTitle;

  /// tutorialSkip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// tutorialNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// tutorialDone
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get tutorialDone;

  /// tutorialInviteTitle
  ///
  /// In en, this message translates to:
  /// **'Invite your people'**
  String get tutorialInviteTitle;

  /// tutorialInviteBody
  ///
  /// In en, this message translates to:
  /// **'Swipe a group right → Invite. Your partner sees the same list.'**
  String get tutorialInviteBody;

  /// tutorialAddTitle
  ///
  /// In en, this message translates to:
  /// **'Add a product'**
  String get tutorialAddTitle;

  /// tutorialAddBody
  ///
  /// In en, this message translates to:
  /// **'Tap + at the bottom of the list. Name, qty, section, priority — done.'**
  String get tutorialAddBody;

  /// tutorialEditTitle
  ///
  /// In en, this message translates to:
  /// **'Edit and check off'**
  String get tutorialEditTitle;

  /// tutorialEditBody
  ///
  /// In en, this message translates to:
  /// **'Tap the checkbox — bought. Tap the row — details and edits.'**
  String get tutorialEditBody;

  /// tutorialDeleteTitle
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tutorialDeleteTitle;

  /// tutorialDeleteBody
  ///
  /// In en, this message translates to:
  /// **'Swipe a product left → Delete. Confirmation can be turned off.'**
  String get tutorialDeleteBody;

  /// tutorialAiTitle
  ///
  /// In en, this message translates to:
  /// **'Import a recipe'**
  String get tutorialAiTitle;

  /// tutorialAiBody
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe URL, tap Parse. Ingredients drop into the list, duplicates marked.'**
  String get tutorialAiBody;

  /// tutorialSettingsTitle
  ///
  /// In en, this message translates to:
  /// **'Everything in reach'**
  String get tutorialSettingsTitle;

  /// tutorialSettingsBody
  ///
  /// In en, this message translates to:
  /// **'Theme, language, notifications, confirmations — Profile → Advanced settings.'**
  String get tutorialSettingsBody;

  /// showTutorial
  ///
  /// In en, this message translates to:
  /// **'Show tutorial'**
  String get showTutorial;

  /// sample group name in invite animation
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get tutorialSampleGroupFamily;

  /// sample product
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get tutorialSampleMilk;

  /// sample product
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get tutorialSampleBread;

  /// sample product added in add animation
  ///
  /// In en, this message translates to:
  /// **'Avocado'**
  String get tutorialSampleAvocado;

  /// sample product with qty
  ///
  /// In en, this message translates to:
  /// **'Milk 2×1L'**
  String get tutorialSampleMilkQty;

  /// sample product
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get tutorialSampleCoffee;

  /// sample product deleted
  ///
  /// In en, this message translates to:
  /// **'Cola'**
  String get tutorialSampleCola;

  /// sample recipe url shown in AI import animation
  ///
  /// In en, this message translates to:
  /// **'recipe.example/pasta'**
  String get tutorialSampleRecipeUrl;

  /// sample recipe ingredient
  ///
  /// In en, this message translates to:
  /// **'Spaghetti 400 g'**
  String get tutorialSampleIngredient1;

  /// sample recipe ingredient
  ///
  /// In en, this message translates to:
  /// **'Tomatoes 500 g'**
  String get tutorialSampleIngredient2;

  /// sample recipe ingredient
  ///
  /// In en, this message translates to:
  /// **'Garlic 3 cloves'**
  String get tutorialSampleIngredient3;

  /// toggle label in settings animation
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get tutorialSampleToggleTheme;

  /// toggle label in settings animation
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tutorialSampleToggleNotif;

  /// toggle label in settings animation
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get tutorialSampleToggleConfirm;

  /// tutorialConnectTitle
  ///
  /// In en, this message translates to:
  /// **'Join by code'**
  String get tutorialConnectTitle;

  /// tutorialConnectBody
  ///
  /// In en, this message translates to:
  /// **'Partner sends a link or code. Paste it — you\'re in the shared list.'**
  String get tutorialConnectBody;

  /// tutorialNotifyTitle
  ///
  /// In en, this message translates to:
  /// **'Ping «need it now»'**
  String get tutorialNotifyTitle;

  /// tutorialNotifyBody
  ///
  /// In en, this message translates to:
  /// **'Tap «!» on a product — your partner gets a push «buy it now». No calls needed.'**
  String get tutorialNotifyBody;

  /// tutorialOutroTitle
  ///
  /// In en, this message translates to:
  /// **'You\'ll figure out the rest'**
  String get tutorialOutroTitle;

  /// tutorialOutroBody
  ///
  /// In en, this message translates to:
  /// **'Tap, swipe, mess up — the app forgives almost anything.'**
  String get tutorialOutroBody;

  /// sample invite code in connect animation
  ///
  /// In en, this message translates to:
  /// **'PORA-4F72'**
  String get tutorialSampleInviteCode;

  /// sample partner name in notify push preview
  ///
  /// In en, this message translates to:
  /// **'Anna'**
  String get tutorialSamplePushSender;

  /// sample push body in notify animation
  ///
  /// In en, this message translates to:
  /// **'Need milk, urgent'**
  String get tutorialSamplePushBody;

  /// sample chat message text before the invite link
  ///
  /// In en, this message translates to:
  /// **'Join the list'**
  String get tutorialSampleInviteMessage;

  /// Email support
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get supportMessage;

  /// Your message will be sent to the support team. Please provide as much detail as possible.
  ///
  /// In en, this message translates to:
  /// **'Your message will be sent to the support team. Please provide as much detail as possible.'**
  String get supportMessageBottomSheetTopDescription;

  /// Send button text in support message bottom bar
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supportMessageBottomSheetSendButton;

  /// supportMessageBottomSheetUnderButtonText
  ///
  /// In en, this message translates to:
  /// **'We will answer as soon as possible, and mail to your gmail or inapp!'**
  String get supportMessageBottomSheetUnderButtonText;

  /// Allergen toggle label
  ///
  /// In en, this message translates to:
  /// **'Allergen'**
  String get allergen;

  /// predictions main greeting
  ///
  /// In en, this message translates to:
  /// **'Your day with PORA'**
  String get predictionsGreeting;

  /// predictions greeting subtitle
  ///
  /// In en, this message translates to:
  /// **'Smart hints from your purchases'**
  String get predictionsGreetingSub;

  /// section title
  ///
  /// In en, this message translates to:
  /// **'Running out soon'**
  String get predictionsSectionSoon;

  /// section title
  ///
  /// In en, this message translates to:
  /// **'AI suggests'**
  String get predictionsSectionAiSuggests;

  /// refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get kpiWeek;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'bought often'**
  String get kpiRecipes;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'running out'**
  String get kpiDaysToRun;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Store herbs like a bouquet: in a glass of water covered with a bag — lasts 2 weeks.'**
  String get fallbackTip1;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Add salt to dough at the end — it slows down yeast.'**
  String get fallbackTip2;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'To stop onions stinging, chill them for 15 minutes in the freezer before cutting.'**
  String get fallbackTip3;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Oversalted soup? A raw potato for 10 minutes soaks up the extra salt.'**
  String get fallbackTip4;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Check egg freshness in water: sinks — fresh, floats — discard.'**
  String get fallbackTip5;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Reheat pizza in a covered skillet — the crust crisps back up.'**
  String get fallbackTip6;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Frozen meat slices thinner — 20 minutes in the freezer before cutting.'**
  String get fallbackTip7;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Roll a lemon on the counter before cutting — you\'ll get more juice.'**
  String get fallbackTip8;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'A pinch of sugar in tomato sauce cuts the acidity.'**
  String get fallbackTip9;

  /// fallback tip
  ///
  /// In en, this message translates to:
  /// **'Bread keeps a month in the freezer; toasting it goes straight from frozen.'**
  String get fallbackTip10;

  /// kicker
  ///
  /// In en, this message translates to:
  /// **'TIP OF THE DAY'**
  String get aiTipOfDayLabel;

  /// default topic passed to tip prompt
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get aiTipOfDayTopic;

  /// CTA title
  ///
  /// In en, this message translates to:
  /// **'Ask PORA'**
  String get aiCtaTitle;

  /// CTA subtitle
  ///
  /// In en, this message translates to:
  /// **'recipes · swaps · tips'**
  String get aiCtaSubtitle;

  /// chat sheet title
  ///
  /// In en, this message translates to:
  /// **'PORA'**
  String get chatSheetTitle;

  /// chat sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'ask about food, groceries, substitutions'**
  String get chatSheetSubtitle;

  /// chat empty state title
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get chatEmptyTitle;

  /// chat empty state examples label
  ///
  /// In en, this message translates to:
  /// **'Example questions:'**
  String get chatEmptyExamplesLabel;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'What can I cook with chicken and rice?'**
  String get chatSample1;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'What can substitute sour cream in dough?'**
  String get chatSample2;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'How do I store herbs so they don\'t wilt?'**
  String get chatSample3;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'Quick 20-minute dinner recipe'**
  String get chatSample4;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'How can I use up vegetables before they spoil?'**
  String get chatSample5;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'Make a shopping list for 3 easy breakfasts'**
  String get chatSample6;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'What should I cook for two with a small budget?'**
  String get chatSample7;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'How long can I keep cooked rice in the fridge?'**
  String get chatSample8;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'Give me a high-protein vegetarian dinner'**
  String get chatSample9;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'What can replace butter in this recipe?'**
  String get chatSample10;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'Plan three dinners from what I already have'**
  String get chatSample11;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'What can I cook with leftovers in 15 minutes?'**
  String get chatSample12;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'Suggest an allergy-safe recipe from my list'**
  String get chatSample13;

  /// sample question
  ///
  /// In en, this message translates to:
  /// **'How can I make this meal cheaper?'**
  String get chatSample14;

  /// typing indicator
  ///
  /// In en, this message translates to:
  /// **'PORA is typing…'**
  String get chatTyping;

  /// chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask anything…'**
  String get chatInputHint;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'herbs'**
  String get tipTopicHerbs;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'baking'**
  String get tipTopicBaking;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'soups'**
  String get tipTopicSoups;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'meat'**
  String get tipTopicMeat;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'fish'**
  String get tipTopicFish;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'vegetables'**
  String get tipTopicVegetables;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'food storage'**
  String get tipTopicStorage;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'kitchen hacks'**
  String get tipTopicKitchenHacks;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'spices'**
  String get tipTopicSpices;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'dough'**
  String get tipTopicDough;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'breakfasts'**
  String get tipTopicBreakfast;

  /// predefined tip topic
  ///
  /// In en, this message translates to:
  /// **'dinners'**
  String get tipTopicDinner;

  /// settings section title
  ///
  /// In en, this message translates to:
  /// **'Tip topics'**
  String get tipTopicsSectionTitle;

  /// settings section description
  ///
  /// In en, this message translates to:
  /// **'Pick which topics the tip is drawn from'**
  String get tipTopicsSectionDescription;

  /// add custom topic hint
  ///
  /// In en, this message translates to:
  /// **'Add your own topic'**
  String get tipTopicsAddCustom;

  /// custom topics label
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get tipTopicsCustomLabel;

  /// predefined topics label
  ///
  /// In en, this message translates to:
  /// **'Predefined'**
  String get tipTopicsPredefinedLabel;

  /// warning when no topics selected
  ///
  /// In en, this message translates to:
  /// **'No topics selected — tip will be generic'**
  String get tipTopicsEmpty;

  /// insightsChampionKicker
  ///
  /// In en, this message translates to:
  /// **'YOUR TOP PRODUCT'**
  String get insightsChampionKicker;

  /// insightsChampionSubtitle
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{bought once} other{bought {count} times}}'**
  String insightsChampionSubtitle(int count);

  /// insightsStreakDays
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{days} day in a row} other{{days} days in a row}}'**
  String insightsStreakDays(int days);

  /// streak card subtitle
  ///
  /// In en, this message translates to:
  /// **'you\'re on it — keep going'**
  String get insightsStreakSubtitle;

  /// frequency subtitle
  ///
  /// In en, this message translates to:
  /// **'~every {days}d'**
  String insightsFreqEvery(int days);

  /// popular section title
  ///
  /// In en, this message translates to:
  /// **'You buy often'**
  String get insightsPopular;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get insightsStatsProducts;

  /// empty state on insights
  ///
  /// In en, this message translates to:
  /// **'No data yet — start adding products'**
  String get insightsEmpty;

  /// filter chip
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// filter chip
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get notificationsFilterUrgent;

  /// filter chip
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get notificationsFilterPrediction;

  /// filter chip
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get notificationsFilterPromo;

  /// filter chip
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get notificationsFilterOther;

  /// menu action
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notificationsClearAll;

  /// slidable action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notificationsDelete;

  /// group header
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsGroupToday;

  /// group header
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsGroupYesterday;

  /// empty state title
  ///
  /// In en, this message translates to:
  /// **'All quiet'**
  String get notificationsEmptyTitle;

  /// empty state body
  ///
  /// In en, this message translates to:
  /// **'New notifications will appear here'**
  String get notificationsEmptyBody;

  /// recipe cta
  ///
  /// In en, this message translates to:
  /// **'Where to add this recipe?'**
  String get recipeCreateListCta;

  /// snackbar when write attempted offline
  ///
  /// In en, this message translates to:
  /// **'No internet — change won\'t be saved'**
  String get offlineWriteBlocked;

  /// snackbar when an offline change was queued for sync
  ///
  /// In en, this message translates to:
  /// **'Saved. We\'ll send it when you\'re back online'**
  String get offlineSavedQueued;

  /// snackbar when queued offline changes were rejected by the server
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync changes: {count}'**
  String offlineSyncDropped(int count);

  /// top banner when cached data shown
  ///
  /// In en, this message translates to:
  /// **'Offline — showing cached data'**
  String get offlineReadBanner;

  /// chat bubble cta
  ///
  /// In en, this message translates to:
  /// **'Import recipe'**
  String get chatImportRecipeCta;

  /// You don't have any lists yet
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any lists yet'**
  String get listsEmptyTitle;

  /// Maybe you should create a new one?
  ///
  /// In en, this message translates to:
  /// **'Maybe you should create a new one?'**
  String get listsEmptySubtitle;

  /// aiModelSettingsSection
  ///
  /// In en, this message translates to:
  /// **'Pora-AI model'**
  String get aiModelSettingsSection;

  /// aiConfigRow
  ///
  /// In en, this message translates to:
  /// **'Custom Pora-AI model'**
  String get aiConfigRow;

  /// aiConfigRowSubtitle
  ///
  /// In en, this message translates to:
  /// **'Use your own OpenRouter key and models'**
  String get aiConfigRowSubtitle;

  /// aiConfigTitle
  ///
  /// In en, this message translates to:
  /// **'Pora-AI model'**
  String get aiConfigTitle;

  /// aiConfigIntro
  ///
  /// In en, this message translates to:
  /// **'Connect your own OpenRouter API key and pick the models that power Pora-AI. Leave a field empty to use the app default.'**
  String get aiConfigIntro;

  /// aiConfigApiKeyLabel
  ///
  /// In en, this message translates to:
  /// **'OpenRouter API key'**
  String get aiConfigApiKeyLabel;

  /// aiConfigApiKeyHint
  ///
  /// In en, this message translates to:
  /// **'sk-or-...'**
  String get aiConfigApiKeyHint;

  /// aiConfigModelsSection
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get aiConfigModelsSection;

  /// aiConfigPoraModelLabel
  ///
  /// In en, this message translates to:
  /// **'PORA-AI model'**
  String get aiConfigPoraModelLabel;

  /// aiConfigPoraModelHint
  ///
  /// In en, this message translates to:
  /// **'e.g. openai/gpt-4o-mini'**
  String get aiConfigPoraModelHint;

  /// aiConfigTipsModelLabel
  ///
  /// In en, this message translates to:
  /// **'Tips model'**
  String get aiConfigTipsModelLabel;

  /// aiConfigTipsModelHint
  ///
  /// In en, this message translates to:
  /// **'Empty — same as app default'**
  String get aiConfigTipsModelHint;

  /// aiConfigNeedKeyNote
  ///
  /// In en, this message translates to:
  /// **'Enter your API key to choose custom models'**
  String get aiConfigNeedKeyNote;

  /// aiConfigReset
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get aiConfigReset;

  /// aiConfigSaved
  ///
  /// In en, this message translates to:
  /// **'Pora-AI settings saved'**
  String get aiConfigSaved;

  /// aiConfigResetDone
  ///
  /// In en, this message translates to:
  /// **'Restored default Pora-AI settings'**
  String get aiConfigResetDone;

  /// aiConfigInfoTitle
  ///
  /// In en, this message translates to:
  /// **'How to connect your model'**
  String get aiConfigInfoTitle;

  /// aiConfigInfoBody
  ///
  /// In en, this message translates to:
  /// **'1. Create a free account at openrouter.ai.\n2. Open Keys and create a new API key, then paste it here.\n3. Browse openrouter.ai/models and copy a model id (for example openai/gpt-4o-mini or anthropic/claude-3.5-sonnet).\n4. Paste the id into the PORA-AI field. The Tips field is optional — leave it empty to reuse the app default model with your key.\n\nYour key is stored only on this device and is used solely for your Pora-AI requests.'**
  String get aiConfigInfoBody;

  /// aiConfigInfoClose
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get aiConfigInfoClose;

  /// supportEmptyError
  ///
  /// In en, this message translates to:
  /// **'Please write a message first'**
  String get supportEmptyError;

  /// supportSent
  ///
  /// In en, this message translates to:
  /// **'Message sent — we\'ll get back to you soon'**
  String get supportSent;

  /// supportFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Check your connection and try again'**
  String get supportFailed;

  /// supportSheetHint
  ///
  /// In en, this message translates to:
  /// **'Describe your issue or feedback...'**
  String get supportSheetHint;

  /// App shortcut: add item
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get shortcutAddItem;

  /// No description provided for @importantReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy {product}'**
  String importantReminderTitle(String product);

  /// No description provided for @importantReminderFrom.
  ///
  /// In en, this message translates to:
  /// **'from {user}'**
  String importantReminderFrom(String user);

  /// importantReminderBody
  ///
  /// In en, this message translates to:
  /// **'Mark as bought when done'**
  String get importantReminderBody;

  /// importantReminderMarkBought
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get importantReminderMarkBought;

  /// liveActivityTestRow
  ///
  /// In en, this message translates to:
  /// **'Test Live Activity'**
  String get liveActivityTestRow;

  /// liveActivityTestSample
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get liveActivityTestSample;

  /// listPickerTitle
  ///
  /// In en, this message translates to:
  /// **'Add to which list?'**
  String get listPickerTitle;

  /// listPickerEmpty
  ///
  /// In en, this message translates to:
  /// **'No lists yet — create one first'**
  String get listPickerEmpty;

  /// predictionsAdded
  ///
  /// In en, this message translates to:
  /// **'Added to list'**
  String get predictionsAdded;

  /// shortcutOpenLists
  ///
  /// In en, this message translates to:
  /// **'Open lists'**
  String get shortcutOpenLists;

  /// shortcutOpenPora
  ///
  /// In en, this message translates to:
  /// **'Ask Pora-AI'**
  String get shortcutOpenPora;

  /// insightsPeriodDays
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String insightsPeriodDays(int days);

  /// insightsStreakBest
  ///
  /// In en, this message translates to:
  /// **'Best streak: {days}'**
  String insightsStreakBest(int days);

  /// insightsStreakStart
  ///
  /// In en, this message translates to:
  /// **'Open Pora every day to build a streak'**
  String get insightsStreakStart;

  /// insightsKpiAdded
  ///
  /// In en, this message translates to:
  /// **'added'**
  String get insightsKpiAdded;

  /// insightsKpiBought
  ///
  /// In en, this message translates to:
  /// **'bought'**
  String get insightsKpiBought;

  /// insightsKpiCompletion
  ///
  /// In en, this message translates to:
  /// **'of added got bought'**
  String get insightsKpiCompletion;

  /// insightsKpiActiveDays
  ///
  /// In en, this message translates to:
  /// **'active days'**
  String get insightsKpiActiveDays;

  /// insightsKpiMinutes
  ///
  /// In en, this message translates to:
  /// **'minutes in app'**
  String get insightsKpiMinutes;

  /// insightsKpiSessions
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get insightsKpiSessions;

  /// insightsAvgSession
  ///
  /// In en, this message translates to:
  /// **'≈{minutes} min per session'**
  String insightsAvgSession(String minutes);

  /// insightsActivityTitle
  ///
  /// In en, this message translates to:
  /// **'Added and bought'**
  String get insightsActivityTitle;

  /// insightsActivityEmpty
  ///
  /// In en, this message translates to:
  /// **'No activity in this period yet'**
  String get insightsActivityEmpty;

  /// insightsHeatmapTitle
  ///
  /// In en, this message translates to:
  /// **'Activity · last 4 weeks'**
  String get insightsHeatmapTitle;

  /// insightsLess
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get insightsLess;

  /// insightsMore
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get insightsMore;

  /// insightsRhythmTitle
  ///
  /// In en, this message translates to:
  /// **'Your rhythm'**
  String get insightsRhythmTitle;

  /// insightsPartMorning
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get insightsPartMorning;

  /// insightsPartAfternoon
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get insightsPartAfternoon;

  /// insightsPartEvening
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get insightsPartEvening;

  /// insightsPartNight
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get insightsPartNight;

  /// insightsPeakMorning
  ///
  /// In en, this message translates to:
  /// **'You\'re most active in the morning'**
  String get insightsPeakMorning;

  /// insightsPeakAfternoon
  ///
  /// In en, this message translates to:
  /// **'You\'re most active in the afternoon'**
  String get insightsPeakAfternoon;

  /// insightsPeakEvening
  ///
  /// In en, this message translates to:
  /// **'You\'re most active in the evening'**
  String get insightsPeakEvening;

  /// insightsPeakNight
  ///
  /// In en, this message translates to:
  /// **'You\'re most active at night'**
  String get insightsPeakNight;

  /// insightsPeakWeekday
  ///
  /// In en, this message translates to:
  /// **'Busiest day — {day}'**
  String insightsPeakWeekday(String day);

  /// insightsCategoriesTitle
  ///
  /// In en, this message translates to:
  /// **'What you add'**
  String get insightsCategoriesTitle;

  /// insightsDueSoonTitle
  ///
  /// In en, this message translates to:
  /// **'Time to restock'**
  String get insightsDueSoonTitle;

  /// insightsDueNow
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get insightsDueNow;

  /// insightsDueInDays
  ///
  /// In en, this message translates to:
  /// **'in ~{days}d'**
  String insightsDueInDays(int days);

  /// insightsTopBoughtTitle
  ///
  /// In en, this message translates to:
  /// **'Bought most this period'**
  String get insightsTopBoughtTitle;

  /// insightsEngagementTitle
  ///
  /// In en, this message translates to:
  /// **'How you use Pora'**
  String get insightsEngagementTitle;

  /// insightsKpiListsOpened
  ///
  /// In en, this message translates to:
  /// **'lists opened'**
  String get insightsKpiListsOpened;

  /// insightsKpiListsCreated
  ///
  /// In en, this message translates to:
  /// **'lists created'**
  String get insightsKpiListsCreated;

  /// insightsKpiRecipes
  ///
  /// In en, this message translates to:
  /// **'recipes imported'**
  String get insightsKpiRecipes;

  /// insightsKpiAi
  ///
  /// In en, this message translates to:
  /// **'messages to Pora'**
  String get insightsKpiAi;

  /// insightsKpiDeleted
  ///
  /// In en, this message translates to:
  /// **'items deleted'**
  String get insightsKpiDeleted;

  /// insightsAllTimeTitle
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get insightsAllTimeTitle;

  /// insightsKpiReminders
  ///
  /// In en, this message translates to:
  /// **'with reminders'**
  String get insightsKpiReminders;

  /// insightsKpiUrgent
  ///
  /// In en, this message translates to:
  /// **'urgent'**
  String get insightsKpiUrgent;

  /// insightsLocalNote
  ///
  /// In en, this message translates to:
  /// **'Usage stats on this screen are calculated on your device'**
  String get insightsLocalNote;

  /// insightsNoUsageYet
  ///
  /// In en, this message translates to:
  /// **'Stats will appear as you use Pora'**
  String get insightsNoUsageYet;

  /// settingsDeleteAccount
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// deleteAccountTitle
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// deleteAccountBody
  ///
  /// In en, this message translates to:
  /// **'Your profile, personal lists and usage data will be permanently deleted. Shared family lists stay with the family; if you own a family, it passes to its longest-standing member. This cannot be undone.'**
  String get deleteAccountBody;

  /// deleteAccountFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the account. Check your connection and try again.'**
  String get deleteAccountFailed;

  /// chatReportAi
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReportAi;

  /// chatReportSent
  ///
  /// In en, this message translates to:
  /// **'Thanks — we\'ll review this answer.'**
  String get chatReportSent;

  /// chatReportFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the report. Try again later.'**
  String get chatReportFailed;

  /// aiDisclaimer
  ///
  /// In en, this message translates to:
  /// **'Pora AI can make mistakes. Check important information.'**
  String get aiDisclaimer;

  /// groupLeave
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupLeave;

  /// groupLeaveTitle
  ///
  /// In en, this message translates to:
  /// **'Leave this group? Its list stays with the other members.'**
  String get groupLeaveTitle;

  /// groupDeleteOwnerOnly
  ///
  /// In en, this message translates to:
  /// **'Only the group owner can delete it'**
  String get groupDeleteOwnerOnly;

  /// groupDeleteFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the group. Try again.'**
  String get groupDeleteFailed;

  /// groupLeaveFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t leave the group. Try again.'**
  String get groupLeaveFailed;

  /// Empty state title of a list without products
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get listNoProductsTitle;

  /// Empty state subtitle of a list without products
  ///
  /// In en, this message translates to:
  /// **'Tap “Add” to put the first one on the list'**
  String get listNoProductsSubtitle;

  /// Display label of stored unit 'шт'
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPcs;

  /// Display label of stored unit 'г'
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// Display label of stored unit 'кг'
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// Display label of stored unit 'мл'
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// Display label of stored unit 'л'
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get unitL;

  /// Display label of stored unit 'уп'
  ///
  /// In en, this message translates to:
  /// **'pack'**
  String get unitPack;

  /// Display label of stored section 'Овощи и фрукты'
  ///
  /// In en, this message translates to:
  /// **'Fruit & vegetables'**
  String get sectionProduce;

  /// Display label of stored section 'Молочное'
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get sectionDairy;

  /// Display label of stored section 'Бакалея'
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get sectionPantry;

  /// Display label of stored section 'Напитки'
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get sectionDrinks;

  /// Display label of stored section 'Хлеб'
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get sectionBread;

  /// Display label of stored section 'Разное'
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get sectionMisc;

  /// Display label of server section 'Прочее' (items without a section)
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sectionOther;

  /// Product runs out daily (prediction card)
  ///
  /// In en, this message translates to:
  /// **'~every day'**
  String get predictionEveryDay;

  /// How often a product runs out, in days (prediction card); 1 day uses predictionEveryDay
  ///
  /// In en, this message translates to:
  /// **'{days, plural, other{~every {days} days}}'**
  String predictionEvery(int days);

  /// Prediction card meta when the cycle length is unknown
  ///
  /// In en, this message translates to:
  /// **'Bought regularly'**
  String get predictionBoughtRegularly;

  /// Product was bought today (prediction card)
  ///
  /// In en, this message translates to:
  /// **'bought today'**
  String get predictionBoughtToday;

  /// Product was bought yesterday (prediction card)
  ///
  /// In en, this message translates to:
  /// **'bought yesterday'**
  String get predictionBoughtYesterday;

  /// Days since the product was last bought, 2+ (prediction card)
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{bought {days} day ago} other{bought {days} days ago}}'**
  String predictionBoughtDaysAgo(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
