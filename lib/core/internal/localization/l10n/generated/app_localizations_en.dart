// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get onlyYou => 'Only you';

  @override
  String get sendAgainAfter => 'Send again in...';

  @override
  String get authPrivatePolicy =>
      'By continuing, you agree to the\nTerms and Privacy Policy';

  @override
  String get authTitle => 'Almost there';

  @override
  String get authSubtitle =>
      'Enter your phone number or email — we\'ll send you a sign-in code.';

  @override
  String get authSubtitle2 =>
      'Start typing — we\'ll detect whether it\'s a phone number or email.';

  @override
  String get authJoinButton => 'Join';

  @override
  String get userCreateProfileNameRequired => 'How about telling us your name?';

  @override
  String get commonError => 'Error';

  @override
  String get authErrorInvalidPhone => 'Invalid phone / email!';

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
  String get otpTitle => 'Almost there!';

  @override
  String get otpEnterCodeSentTo => 'Enter the code sent to ';

  @override
  String get otpResendQuestion => 'Didn\'t receive the code?';

  @override
  String get otpResend => 'Send again';

  @override
  String get otpVerifyButton => 'Verify code';

  @override
  String get otpValidationLength => 'Enter the 6-digit code';

  @override
  String get otpValidationDigits => 'The code contains digits only';

  @override
  String get authSwitchToEmail => 'Sign in with email';

  @override
  String get authSwitchToPhone => 'Sign in with phone';

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingSlide1Title => 'Recipe → list\nin seconds';

  @override
  String get onboardingSlide1Body =>
      'Drop a recipe link — Pora collects the ingredients and removes what you already have.';

  @override
  String get onboardingSlide2Title => 'One list\nfor two';

  @override
  String get onboardingSlide2Body =>
      'Add things together — you can see who added what. Your partner can pick up what you need on the way home.';

  @override
  String get onboardingSlide3Title => 'Pora knows\nwhen it\'s time';

  @override
  String get onboardingSlide3Body =>
      'Based on your purchases, Pora predicts what will run out soon and reminds you to add it to your list.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingNext => 'Next';

  @override
  String get splashTagline => 'The list that remembers for you';

  @override
  String get briefTitle => 'What do you often run out of?';

  @override
  String get briefDeletionTitle =>
      'Are you sure you want to delete this product?';

  @override
  String get briefAddYourOwn => 'Add';

  @override
  String get briefInputProduct => 'Enter a product or category';

  @override
  String get briefInputEmoji => 'Enter an emoji/icon for the product';

  @override
  String get briefAlreadyContains => 'This product is already selected';

  @override
  String get briefSubtitle =>
      'Select products — Pora will remind you at the right time. You can skip this.';

  @override
  String get briefSkip => 'Skip';

  @override
  String get briefNext => 'Next';

  @override
  String get listUrgent => 'Urgent';

  @override
  String get listAdd => 'Add';

  @override
  String get predictionsAddToList => 'Add to list';

  @override
  String get predictionsDismiss => 'No thanks';

  @override
  String get itemDetailAddedBy => 'Added by';

  @override
  String get itemDetailQuantity => 'Quantity';

  @override
  String get itemDetailUrgent => 'Urgent';

  @override
  String get itemDetailRemind => 'Remind me';

  @override
  String get itemDetailMarkBought => 'Mark as bought';

  @override
  String get itemDetailDelete => 'Remove from list';

  @override
  String get addItemQuantity => 'Quantity';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Privacy and data';

  @override
  String get settingsAboutPora => 'About Pora';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsInvitePill => 'Invite';

  @override
  String get householdInviteTitle => 'Invite your partner';

  @override
  String get householdCookTogether => 'Cook together';

  @override
  String get householdInviteDescription =>
      'Pora works better for two. Invite your partner — your list and reminders will be shared.';

  @override
  String get householdShareLink => 'Share link';

  @override
  String get householdShowQr => 'Show QR code';

  @override
  String get householdConnectToFamily => 'Join a family';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      'We detected an invite code, but you can enter it yourself if we got it wrong';

  @override
  String get householdGotInvited => 'You\'ve been invited to a family';

  @override
  String get householdDoLater => 'I\'ll do it later';

  @override
  String get householdCopyCode => 'Copied to clipboard!';

  @override
  String get householdInviteCodeLabel => 'Invite code';

  @override
  String get householdCopyPill => 'Copy';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsReadAll => 'Read all';

  @override
  String get notificationsAddToListPill => '＋ Add to list';

  @override
  String get userCreateProfileTitle => 'What\'s your name?';

  @override
  String get userCreateProfileSubtitle =>
      'Add a name and photo — your partner will see them in the shared list.';

  @override
  String get userCreateProfileNameHint => 'Your name';

  @override
  String get userCreateProfileSkip => 'Skip';

  @override
  String get userCreateProfileNext => 'Next';

  @override
  String get searchHint => 'Product or recipe…';

  @override
  String get searchNothingFound => 'Nothing found';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get recipeImportTitle => 'Recipe from a link';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String recipeAddToListCta(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Add $countString product to list';
  }

  @override
  String get recipeParseButton => 'Parse';

  @override
  String get navList => 'List';

  @override
  String get navPora => 'Pora';

  @override
  String get navProfile => 'Profile';

  @override
  String get familiesTitle => 'Families';

  @override
  String get familiesSubtitle => 'Choose a family to open its list';

  @override
  String get familiesCreateDialog => 'What should we call the family?';

  @override
  String get tryToUpdate => 'Try refreshing';

  @override
  String get listsYour => 'Your personal list';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '$count person',
    );
    return '$_temp0';
  }

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return '$_temp0';
  }

  @override
  String listsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '$count list',
    );
    return '$_temp0';
  }

  @override
  String get update => 'Refresh';

  @override
  String get connectionSuccess => 'Joined';

  @override
  String get familiesNoUrgent => 'Nothing urgent';

  @override
  String get welcomeBackTitle => 'Welcome back!';

  @override
  String get welcomeBackSubtitle => 'One second, opening your list…';

  @override
  String get errorDuringLoading => 'Error while loading';

  @override
  String get familyName => 'Family name';

  @override
  String get familiesCreate => 'Create';

  @override
  String get familiesConnect => 'Join';

  @override
  String get showAll => 'Show all';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get everyDay => 'Every day';

  @override
  String get newList => 'New list';

  @override
  String get listNamePlaceholder => 'List name';

  @override
  String get cancel => 'Cancel';

  @override
  String get quantityLabel => 'Qty';

  @override
  String get personal => 'Personal';

  @override
  String get notify => 'Notify';

  @override
  String get notifyEveryone => 'Everyone';

  @override
  String get notifyRecipients => 'To';

  @override
  String get notifyAddCustom => 'Add name';

  @override
  String get notifyMessageLabel => 'Message';

  @override
  String notifyHint(String itemName) {
    return 'Grab $itemName urgently';
  }

  @override
  String get notifySend => 'Send';

  @override
  String get notifySent => 'Notification sent';

  @override
  String get advancedSettings => 'Advanced settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get notificationsPermission => 'Notifications permission';

  @override
  String get granted => 'Granted';

  @override
  String get denied => 'Denied';

  @override
  String get notDetermined => 'Not requested';

  @override
  String get requestPermission => 'Request';

  @override
  String get confirmations => 'Confirmations';

  @override
  String get askBeforeDelete => 'Ask before deletion';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get deleteItemTitle => 'Delete item?';

  @override
  String get deleteItemBody => 'This cannot be undone.';

  @override
  String get dontAskAgain => 'Don\'t ask again';

  @override
  String get delete => 'Delete';

  @override
  String get returnToList => 'Return to list';

  @override
  String get nooneToNotify => 'No one to notify';

  @override
  String get notFound => 'Not found';

  @override
  String get recipeEmptyHint => 'Paste a recipe URL and tap “Parse”';

  @override
  String get done => 'Done';

  @override
  String get errorGeneric => 'Error';

  @override
  String get pushToken => 'Push token';

  @override
  String get resync => 'Sync';

  @override
  String get tokenSynced => 'Token synced';

  @override
  String get deleteListTitle => 'Delete list?';

  @override
  String deleteListBody(String listName) {
    return 'List “$listName” and all its items will be deleted. This cannot be undone.';
  }

  @override
  String get membersScreenTitle => 'Members';

  @override
  String get owner => 'Owner';

  @override
  String get member => 'Member';

  @override
  String get addProduct => 'Add product';

  @override
  String get productName => 'Name';

  @override
  String get section => 'Section';

  @override
  String get unit => 'Unit';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMed => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get urgent => 'Urgent';

  @override
  String get remindEvery => 'Remind every';

  @override
  String get days => 'd';

  @override
  String get customValue => 'Custom…';

  @override
  String get save => 'Save';

  @override
  String addedByName(String name) {
    return 'Added by: $name';
  }

  @override
  String get splashLoadingSlow => 'Almost there…';

  @override
  String get splashLoadingVerySlow => 'Still loading… checking connection';

  @override
  String get profileNameUpdate => 'Profile updating';

  @override
  String get briefSnackBar => 'Maybe you forgot to select any products?';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get noInternetButLoadYouLocally =>
      'No internet connection, but we will load you locally';

  @override
  String get groupDeletionTitle => 'Are you sure want to delete group?';

  @override
  String get retry => 'Retry';

  @override
  String get groupsTitle => 'Your groups';

  @override
  String get groupsSubtitle =>
      'A list is a group. Invite people — they\'ll see the list.';

  @override
  String get groupCreate => 'Create group';

  @override
  String get groupConnect => 'Join';

  @override
  String get groupNameHint => 'Group name';

  @override
  String get groupPersonal => 'Personal';

  @override
  String get groupShared => 'Shared';

  @override
  String get tutorialTitle => 'How it works';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialDone => 'Start';

  @override
  String get tutorialInviteTitle => 'Invite your people';

  @override
  String get tutorialInviteBody =>
      'Swipe a group right → Invite. Your partner sees the same list.';

  @override
  String get tutorialAddTitle => 'Add a product';

  @override
  String get tutorialAddBody =>
      'Tap + at the bottom of the list. Name, qty, section, priority — done.';

  @override
  String get tutorialEditTitle => 'Edit and check off';

  @override
  String get tutorialEditBody =>
      'Tap the checkbox — bought. Tap the row — details and edits.';

  @override
  String get tutorialDeleteTitle => 'Delete';

  @override
  String get tutorialDeleteBody =>
      'Swipe a product left → Delete. Confirmation can be turned off.';

  @override
  String get tutorialAiTitle => 'Import a recipe';

  @override
  String get tutorialAiBody =>
      'Paste a recipe URL, tap Parse. Ingredients drop into the list, duplicates marked.';

  @override
  String get tutorialSettingsTitle => 'Everything in reach';

  @override
  String get tutorialSettingsBody =>
      'Theme, language, notifications, confirmations — Profile → Advanced settings.';

  @override
  String get showTutorial => 'Show tutorial';

  @override
  String get tutorialSampleGroupFamily => 'Family';

  @override
  String get tutorialSampleMilk => 'Milk';

  @override
  String get tutorialSampleBread => 'Bread';

  @override
  String get tutorialSampleAvocado => 'Avocado';

  @override
  String get tutorialSampleMilkQty => 'Milk 2×1L';

  @override
  String get tutorialSampleCoffee => 'Coffee';

  @override
  String get tutorialSampleCola => 'Cola';

  @override
  String get tutorialSampleRecipeUrl => 'recipe.example/pasta';

  @override
  String get tutorialSampleIngredient1 => 'Spaghetti 400 g';

  @override
  String get tutorialSampleIngredient2 => 'Tomatoes 500 g';

  @override
  String get tutorialSampleIngredient3 => 'Garlic 3 cloves';

  @override
  String get tutorialSampleToggleTheme => 'Theme';

  @override
  String get tutorialSampleToggleNotif => 'Notifications';

  @override
  String get tutorialSampleToggleConfirm => 'Confirmation';

  @override
  String get tutorialConnectTitle => 'Join by code';

  @override
  String get tutorialConnectBody =>
      'Partner sends a link or code. Paste it — you\'re in the shared list.';

  @override
  String get tutorialNotifyTitle => 'Ping «need it now»';

  @override
  String get tutorialNotifyBody =>
      'Tap «!» on a product — your partner gets a push «buy it now». No calls needed.';

  @override
  String get tutorialOutroTitle => 'You\'ll figure out the rest';

  @override
  String get tutorialOutroBody =>
      'Tap, swipe, mess up — the app forgives almost anything.';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => 'Anna';

  @override
  String get tutorialSamplePushBody => 'Need milk, urgent';

  @override
  String get tutorialSampleInviteMessage => 'Join the list';

  @override
  String get supportMessage => 'Email support';

  @override
  String get supportMessageBottomSheetTopDescription =>
      'Your message will be sent to the support team. Please provide as much detail as possible.';

  @override
  String get supportMessageBottomSheetSendButton => 'Send';

  @override
  String get supportMessageBottomSheetUnderButtonText =>
      'We will answer as soon as possible, and mail to your gmail or inapp!';

  @override
  String get allergen => 'Allergen';

  @override
  String get predictionsGreeting => 'Your day with PORA';

  @override
  String get predictionsGreetingSub => 'Smart hints from your purchases';

  @override
  String get predictionsSectionSoon => 'Running out soon';

  @override
  String get predictionsSectionAiSuggests => 'AI suggests';

  @override
  String get refresh => 'Refresh';

  @override
  String get kpiWeek => 'products';

  @override
  String get kpiRecipes => 'bought often';

  @override
  String get kpiDaysToRun => 'running out';

  @override
  String get fallbackTip1 =>
      'Store herbs like a bouquet: in a glass of water covered with a bag — lasts 2 weeks.';

  @override
  String get fallbackTip2 =>
      'Add salt to dough at the end — it slows down yeast.';

  @override
  String get fallbackTip3 =>
      'To stop onions stinging, chill them for 15 minutes in the freezer before cutting.';

  @override
  String get fallbackTip4 =>
      'Oversalted soup? A raw potato for 10 minutes soaks up the extra salt.';

  @override
  String get fallbackTip5 =>
      'Check egg freshness in water: sinks — fresh, floats — discard.';

  @override
  String get fallbackTip6 =>
      'Reheat pizza in a covered skillet — the crust crisps back up.';

  @override
  String get fallbackTip7 =>
      'Frozen meat slices thinner — 20 minutes in the freezer before cutting.';

  @override
  String get fallbackTip8 =>
      'Roll a lemon on the counter before cutting — you\'ll get more juice.';

  @override
  String get fallbackTip9 =>
      'A pinch of sugar in tomato sauce cuts the acidity.';

  @override
  String get fallbackTip10 =>
      'Bread keeps a month in the freezer; toasting it goes straight from frozen.';

  @override
  String get aiTipOfDayLabel => 'TIP OF THE DAY';

  @override
  String get aiTipOfDayTopic => 'today';

  @override
  String get aiCtaTitle => 'Ask PORA';

  @override
  String get aiCtaSubtitle => 'recipes · swaps · tips';

  @override
  String get chatSheetTitle => 'PORA';

  @override
  String get chatSheetSubtitle => 'ask about food, groceries, substitutions';

  @override
  String get chatEmptyTitle => 'Start a conversation';

  @override
  String get chatEmptyExamplesLabel => 'Example questions:';

  @override
  String get chatSample1 => 'What can I cook with chicken and rice?';

  @override
  String get chatSample2 => 'What can substitute sour cream in dough?';

  @override
  String get chatSample3 => 'How do I store herbs so they don\'t wilt?';

  @override
  String get chatSample4 => 'Quick 20-minute dinner recipe';

  @override
  String get chatSample5 => 'How can I use up vegetables before they spoil?';

  @override
  String get chatSample6 => 'Make a shopping list for 3 easy breakfasts';

  @override
  String get chatSample7 => 'What should I cook for two with a small budget?';

  @override
  String get chatSample8 => 'How long can I keep cooked rice in the fridge?';

  @override
  String get chatSample9 => 'Give me a high-protein vegetarian dinner';

  @override
  String get chatSample10 => 'What can replace butter in this recipe?';

  @override
  String get chatSample11 => 'Plan three dinners from what I already have';

  @override
  String get chatSample12 => 'What can I cook with leftovers in 15 minutes?';

  @override
  String get chatSample13 => 'Suggest an allergy-safe recipe from my list';

  @override
  String get chatSample14 => 'How can I make this meal cheaper?';

  @override
  String get chatTyping => 'PORA is typing…';

  @override
  String get chatInputHint => 'Ask anything…';

  @override
  String get tipTopicHerbs => 'herbs';

  @override
  String get tipTopicBaking => 'baking';

  @override
  String get tipTopicSoups => 'soups';

  @override
  String get tipTopicMeat => 'meat';

  @override
  String get tipTopicFish => 'fish';

  @override
  String get tipTopicVegetables => 'vegetables';

  @override
  String get tipTopicStorage => 'food storage';

  @override
  String get tipTopicKitchenHacks => 'kitchen hacks';

  @override
  String get tipTopicSpices => 'spices';

  @override
  String get tipTopicDough => 'dough';

  @override
  String get tipTopicBreakfast => 'breakfasts';

  @override
  String get tipTopicDinner => 'dinners';

  @override
  String get tipTopicsSectionTitle => 'Tip topics';

  @override
  String get tipTopicsSectionDescription =>
      'Pick which topics the tip is drawn from';

  @override
  String get tipTopicsAddCustom => 'Add your own topic';

  @override
  String get tipTopicsCustomLabel => 'Custom';

  @override
  String get tipTopicsPredefinedLabel => 'Predefined';

  @override
  String get tipTopicsEmpty => 'No topics selected — tip will be generic';

  @override
  String get insightsChampionKicker => 'YOUR TOP PRODUCT';

  @override
  String insightsChampionSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bought $count times',
      one: 'bought once',
    );
    return '$_temp0';
  }

  @override
  String insightsStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days in a row',
      one: '$days day in a row',
    );
    return '$_temp0';
  }

  @override
  String get insightsStreakSubtitle => 'you\'re on it — keep going';

  @override
  String insightsFreqEvery(int days) {
    return '~every ${days}d';
  }

  @override
  String get insightsPopular => 'You buy often';

  @override
  String get insightsStatsProducts => 'products';

  @override
  String get insightsEmpty => 'No data yet — start adding products';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterUrgent => 'Urgent';

  @override
  String get notificationsFilterPrediction => 'Predictions';

  @override
  String get notificationsFilterPromo => 'Promo';

  @override
  String get notificationsFilterOther => 'Other';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsDelete => 'Delete';

  @override
  String get notificationsGroupToday => 'Today';

  @override
  String get notificationsGroupYesterday => 'Yesterday';

  @override
  String get notificationsEmptyTitle => 'All quiet';

  @override
  String get notificationsEmptyBody => 'New notifications will appear here';

  @override
  String get recipeCreateListCta => 'Where to add this recipe?';

  @override
  String get offlineWriteBlocked => 'No internet — change won\'t be saved';

  @override
  String get offlineSavedQueued =>
      'Saved. We\'ll send it when you\'re back online';

  @override
  String offlineSyncDropped(int count) {
    return 'Couldn\'t sync changes: $count';
  }

  @override
  String get offlineReadBanner => 'Offline — showing cached data';

  @override
  String get chatImportRecipeCta => 'Import recipe';

  @override
  String get listsEmptyTitle => 'You don\'t have any lists yet';

  @override
  String get listsEmptySubtitle => 'Maybe you should create a new one?';

  @override
  String get aiModelSettingsSection => 'Pora-AI model';

  @override
  String get aiConfigRow => 'Custom Pora-AI model';

  @override
  String get aiConfigRowSubtitle => 'Use your own OpenRouter key and models';

  @override
  String get aiConfigTitle => 'Pora-AI model';

  @override
  String get aiConfigIntro =>
      'Connect your own OpenRouter API key and pick the models that power Pora-AI. Leave a field empty to use the app default.';

  @override
  String get aiConfigApiKeyLabel => 'OpenRouter API key';

  @override
  String get aiConfigApiKeyHint => 'sk-or-...';

  @override
  String get aiConfigModelsSection => 'Models';

  @override
  String get aiConfigPoraModelLabel => 'PORA-AI model';

  @override
  String get aiConfigPoraModelHint => 'e.g. openai/gpt-4o-mini';

  @override
  String get aiConfigTipsModelLabel => 'Tips model';

  @override
  String get aiConfigTipsModelHint => 'Empty — same as app default';

  @override
  String get aiConfigNeedKeyNote =>
      'Enter your API key to choose custom models';

  @override
  String get aiConfigReset => 'Reset to default';

  @override
  String get aiConfigSaved => 'Pora-AI settings saved';

  @override
  String get aiConfigResetDone => 'Restored default Pora-AI settings';

  @override
  String get aiConfigInfoTitle => 'How to connect your model';

  @override
  String get aiConfigInfoBody =>
      '1. Create a free account at openrouter.ai.\n2. Open Keys and create a new API key, then paste it here.\n3. Browse openrouter.ai/models and copy a model id (for example openai/gpt-4o-mini or anthropic/claude-3.5-sonnet).\n4. Paste the id into the PORA-AI field. The Tips field is optional — leave it empty to reuse the app default model with your key.\n\nYour key is stored only on this device and is used solely for your Pora-AI requests.';

  @override
  String get aiConfigInfoClose => 'Got it';

  @override
  String get supportEmptyError => 'Please write a message first';

  @override
  String get supportSent => 'Message sent — we\'ll get back to you soon';

  @override
  String get supportFailed =>
      'Couldn\'t send. Check your connection and try again';

  @override
  String get supportSheetHint => 'Describe your issue or feedback...';

  @override
  String get shortcutAddItem => 'Add item';

  @override
  String importantReminderTitle(String product) {
    return 'Buy $product';
  }

  @override
  String importantReminderFrom(String user) {
    return 'from $user';
  }

  @override
  String get importantReminderBody => 'Mark as bought when done';

  @override
  String get importantReminderMarkBought => 'Bought';

  @override
  String get liveActivityTestRow => 'Test Live Activity';

  @override
  String get liveActivityTestSample => 'Milk';

  @override
  String get listPickerTitle => 'Add to which list?';

  @override
  String get listPickerEmpty => 'No lists yet — create one first';

  @override
  String get predictionsAdded => 'Added to list';

  @override
  String get shortcutOpenLists => 'Open lists';

  @override
  String get shortcutOpenPora => 'Ask Pora-AI';

  @override
  String insightsPeriodDays(int days) {
    return '${days}d';
  }

  @override
  String insightsStreakBest(int days) {
    return 'Best streak: $days';
  }

  @override
  String get insightsStreakStart => 'Open Pora every day to build a streak';

  @override
  String get insightsKpiAdded => 'added';

  @override
  String get insightsKpiBought => 'bought';

  @override
  String get insightsKpiCompletion => 'of added got bought';

  @override
  String get insightsKpiActiveDays => 'active days';

  @override
  String get insightsKpiMinutes => 'minutes in app';

  @override
  String get insightsKpiSessions => 'sessions';

  @override
  String insightsAvgSession(String minutes) {
    return '≈$minutes min per session';
  }

  @override
  String get insightsActivityTitle => 'Added and bought';

  @override
  String get insightsActivityEmpty => 'No activity in this period yet';

  @override
  String get insightsHeatmapTitle => 'Activity · last 4 weeks';

  @override
  String get insightsLess => 'less';

  @override
  String get insightsMore => 'more';

  @override
  String get insightsRhythmTitle => 'Your rhythm';

  @override
  String get insightsPartMorning => 'Morning';

  @override
  String get insightsPartAfternoon => 'Afternoon';

  @override
  String get insightsPartEvening => 'Evening';

  @override
  String get insightsPartNight => 'Night';

  @override
  String get insightsPeakMorning => 'You\'re most active in the morning';

  @override
  String get insightsPeakAfternoon => 'You\'re most active in the afternoon';

  @override
  String get insightsPeakEvening => 'You\'re most active in the evening';

  @override
  String get insightsPeakNight => 'You\'re most active at night';

  @override
  String insightsPeakWeekday(String day) {
    return 'Busiest day — $day';
  }

  @override
  String get insightsCategoriesTitle => 'What you add';

  @override
  String get insightsDueSoonTitle => 'Time to restock';

  @override
  String get insightsDueNow => 'now';

  @override
  String insightsDueInDays(int days) {
    return 'in ~${days}d';
  }

  @override
  String get insightsTopBoughtTitle => 'Bought most this period';

  @override
  String get insightsEngagementTitle => 'How you use Pora';

  @override
  String get insightsKpiListsOpened => 'lists opened';

  @override
  String get insightsKpiListsCreated => 'lists created';

  @override
  String get insightsKpiRecipes => 'recipes imported';

  @override
  String get insightsKpiAi => 'messages to Pora';

  @override
  String get insightsKpiDeleted => 'items deleted';

  @override
  String get insightsAllTimeTitle => 'All time';

  @override
  String get insightsKpiReminders => 'with reminders';

  @override
  String get insightsKpiUrgent => 'urgent';

  @override
  String get insightsLocalNote =>
      'Usage stats on this screen are calculated on your device';

  @override
  String get insightsNoUsageYet => 'Stats will appear as you use Pora';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountBody =>
      'Your profile, personal lists and usage data will be permanently deleted. Shared family lists stay with the family; if you own a family, it passes to its longest-standing member. This cannot be undone.';

  @override
  String get deleteAccountFailed =>
      'Couldn\'t delete the account. Check your connection and try again.';

  @override
  String get chatReportAi => 'Report';

  @override
  String get chatReportSent => 'Thanks — we\'ll review this answer.';

  @override
  String get chatReportFailed => 'Couldn\'t send the report. Try again later.';

  @override
  String get aiDisclaimer =>
      'Pora AI can make mistakes. Check important information.';

  @override
  String get groupLeave => 'Leave';

  @override
  String get groupLeaveTitle =>
      'Leave this group? Its list stays with the other members.';

  @override
  String get groupDeleteOwnerOnly => 'Only the group owner can delete it';

  @override
  String get groupDeleteFailed => 'Couldn\'t delete the group. Try again.';

  @override
  String get groupLeaveFailed => 'Couldn\'t leave the group. Try again.';

  @override
  String get listNoProductsTitle => 'No products yet';

  @override
  String get listNoProductsSubtitle =>
      'Tap “Add” to put the first one on the list';

  @override
  String get unitPcs => 'pcs';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitPack => 'pack';

  @override
  String get sectionProduce => 'Fruit & vegetables';

  @override
  String get sectionDairy => 'Dairy';

  @override
  String get sectionPantry => 'Pantry';

  @override
  String get sectionDrinks => 'Drinks';

  @override
  String get sectionBread => 'Bread';

  @override
  String get sectionMisc => 'Miscellaneous';

  @override
  String get sectionOther => 'Other';

  @override
  String get predictionEveryDay => '~every day';

  @override
  String predictionEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '~every $days days',
    );
    return '$_temp0';
  }

  @override
  String get predictionBoughtRegularly => 'Bought regularly';

  @override
  String get predictionBoughtToday => 'bought today';

  @override
  String get predictionBoughtYesterday => 'bought yesterday';

  @override
  String predictionBoughtDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'bought $days days ago',
      one: 'bought $days day ago',
    );
    return '$_temp0';
  }
}
