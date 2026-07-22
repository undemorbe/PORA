// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pora';

  @override
  String get language => 'Language';

  @override
  String get authUnderAppName1 => 'Общий список для пар и семей';

  @override
  String get authUnderAppName2 => 'Рецепты, дом и доставка — в одном месте';

  @override
  String get authSignInExpansibleExpand => 'Войти иным способом';

  @override
  String get authSignInExpansibleCollapse => 'Свернуть';

  @override
  String get authSignInWithEmail => 'Войти через email';

  @override
  String get authSignInWithGoogle => 'Войти через Google';

  @override
  String get authSignInWithApple => 'Войти через Apple';

  @override
  String get authSignInWithPhone => 'Войти через телефон';

  @override
  String get authPrivatePolicy =>
      'Продолжая, вы соглашаетесь с\nУсловиями и Политикой конфиденциальности';

  @override
  String get authTitle => 'Почти с нами';

  @override
  String get authSubtitle =>
      'Введите номер телефона или почту — пришлём код для входа.';

  @override
  String get authSubtitle2 =>
      'Начните вводить, сами определим, телефон это или почта.';

  @override
  String get authJoinButton => 'Присоединиться';

  @override
  String get userCreateProfileNameRequired => 'Может все-же скажете имя?';

  @override
  String get commonError => 'Ошибка';

  @override
  String get otpTitle => 'Осталось немного!';

  @override
  String get otpEnterCodeSentTo => 'Введите код отправленный на ';

  @override
  String get otpResendQuestion => 'Не получили код?';

  @override
  String get otpResend => 'Отправить еще раз';

  @override
  String get otpVerifyButton => 'Проверить код';

  @override
  String get otpValidationLength => 'Введите 6-значный код';

  @override
  String get otpValidationDigits => 'Код состоит только из цифр';

  @override
  String get authSwitchToEmail => 'Войти по почте';

  @override
  String get authSwitchToPhone => 'Войти по телефону';

  @override
  String onboardingStep(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get onboardingSlide1Title => 'Рецепт → список\nза секунды';

  @override
  String get onboardingSlide1Body =>
      'Киньте ссылку на рецепт — Pora соберёт ингредиенты и уберёт то, что уже есть.';

  @override
  String get onboardingSlide2Title => 'Один список\nна двоих';

  @override
  String get onboardingSlide2Body =>
      'Добавляйте вместе — видно, кто что внёс. Партнёр захватит нужное по дороге домой.';

  @override
  String get onboardingSlide3Title => 'Pora знает,\nкогда пора';

  @override
  String get onboardingSlide3Body =>
      'По вашим покупкам подскажет, что скоро закончится, и закажет в один тап.';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get splashTagline => 'Список, который помнит за вас';

  @override
  String get briefTitle => 'Что у вас часто заканчивается?';

  @override
  String get briefAddYourOwn => 'Добавить';

  @override
  String get briefInputProduct => 'Введите продукт или вид';

  @override
  String get briefInputEmoji => 'Введите эмодзи/обозначение для продукта';

  @override
  String get briefSubtitle =>
      'Отметьте продукты — Pora напомнит вовремя. Это можно пропустить.';

  @override
  String get briefSkip => 'Пропустить';

  @override
  String get briefNext => 'Далее';

  @override
  String get briefItemMilk => 'Молоко';

  @override
  String get briefItemBread => 'Хлеб';

  @override
  String get briefItemEggs => 'Яйца';

  @override
  String get briefItemCoffee => 'Кофе';

  @override
  String get briefItemCheese => 'Сыр';

  @override
  String get briefItemBananas => 'Бананы';

  @override
  String get briefItemButter => 'Масло';

  @override
  String get briefItemWater => 'Вода';

  @override
  String get briefItemVegetables => 'Овощи';

  @override
  String get briefItemTomatoes => 'Помидоры';

  @override
  String get briefItemPasta => 'Паста';

  @override
  String get briefItemChicken => 'Курица';

  @override
  String get listTitle => 'Наш список';

  @override
  String get listMembersCount => '2 человека · 8 продуктов';

  @override
  String get listUrgent => 'Срочно';

  @override
  String get listAdd => 'Добавить';

  @override
  String get predictionsTitle => 'Пора докупить';

  @override
  String get predictionsSubtitle => 'Скоро закончится — по вашим покупкам';

  @override
  String get predictionsOrderTitle => 'Заказать всё в один тап';

  @override
  String get predictionsOrderSubtitle => 'Самокат · доставка за 15 минут';

  @override
  String get predictionsOrderDiscount => '−15% на первый заказ';

  @override
  String get predictionsAddToList => 'В список';

  @override
  String get predictionsDismiss => 'Не надо';

  @override
  String get itemDetailName => 'Молоко';

  @override
  String get itemDetailSubtitle => '2 л · Молочное';

  @override
  String get itemDetailAddedBy => 'Добавил(а)';

  @override
  String get itemDetailSection => 'Раздел';

  @override
  String get itemDetailSectionValue => 'Молочное';

  @override
  String get itemDetailQuantity => 'Количество';

  @override
  String get itemDetailQuantityValue => '2 л';

  @override
  String get itemDetailUrgent => 'Срочно';

  @override
  String get itemDetailRemind => 'Напоминать';

  @override
  String get itemDetailRemindEvery => 'Каждые 7 дней';

  @override
  String get itemDetailInsight =>
      'Покупаете ~раз в 7 дней · последний раз 6 дней назад. Скоро предложу докупить.';

  @override
  String get itemDetailMarkBought => 'Отметить купленным';

  @override
  String get itemDetailDelete => 'Удалить из списка';

  @override
  String get addItemTitle => 'Добавить продукт';

  @override
  String get addItemExampleValue => 'Авокадо';

  @override
  String get addItemNameHint => 'Название продукта';

  @override
  String get addItemQuantity => 'Количество';

  @override
  String get addItemSection => 'Раздел';

  @override
  String get addItemUrgent => 'Срочно';

  @override
  String get addItemUrgentSubtitle => 'Нужно купить сегодня';

  @override
  String get addItemRemind => 'Напоминать регулярно';

  @override
  String get addItemRemindEvery => 'Каждые 7 дней';

  @override
  String get addItemSubmit => 'Добавить в список';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsHouseholdSection => 'Хозяйство';

  @override
  String get settingsAppSection => 'Приложение';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsDelivery => 'Доставка';

  @override
  String get settingsProAd => 'Pora+ · без рекламы';

  @override
  String get settingsTryPill => 'Попробовать';

  @override
  String get settingsPrivacy => 'Приватность и данные';

  @override
  String get settingsAboutPora => 'О Pora';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsMembersNames => 'Борис и Анна';

  @override
  String get settingsInvitePill => 'Пригласить';

  @override
  String get householdInviteTitle => 'Пригласить партнёра';

  @override
  String get householdCookTogether => 'Готовьте вместе';

  @override
  String get householdInviteDescription =>
      'Pora работает лучше вдвоём. Пригласите партнёра — список и напоминания станут общими.';

  @override
  String get householdShareLink => 'Поделиться ссылкой';

  @override
  String get householdShowQr => 'Показать QR-код';

  @override
  String get householdConnectToFamily => 'Подключиться к семье';

  @override
  String get householdInviteDescriptionWhenConnecting =>
      'Определили код приглашения, но вы и сами можете его ввести, если мы ошиблись';

  @override
  String get householdGotInvited => 'Вас пригласили в семью';

  @override
  String get householdWriteCode => 'Введите код приглашения';

  @override
  String get householdDoLater => 'Сделаю позже';

  @override
  String get householdCopyCode => 'Скопировали в буфер обмена!';

  @override
  String get householdInviteCodeLabel => 'Код приглашения';

  @override
  String get householdCopyPill => 'Копировать';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsReadAll => 'Прочитать все';

  @override
  String get notificationsMilkTitle => 'По дороге домой захвати молоко';

  @override
  String get notificationsMilkBody =>
      'Оно кончилось — Анна отметила 10 минут назад.';

  @override
  String get notificationsMilkTime => '5 минут назад';

  @override
  String get notificationsCoffeeTitle => 'Скоро закончится кофе';

  @override
  String get notificationsCoffeeBody => 'Покупаете ~раз в 14 дней, прошло 12.';

  @override
  String get notificationsPartnerAddedTitle => 'Анна добавила 2 продукта';

  @override
  String get notificationsPartnerAddedBody => 'Бананы и Хлеб — в общем списке.';

  @override
  String get notificationsPartnerAddedTime => 'Сегодня, 9:12';

  @override
  String get notificationsPromoTitle => '−15% на первый заказ в Самокате';

  @override
  String get notificationsPromoBody => 'Промо активно ещё 6 дней.';

  @override
  String get notificationsPromoTime => 'Вчера';

  @override
  String get notificationsOrderDeliveredTitle => 'Заказ доставлен';

  @override
  String get notificationsOrderDeliveredBody =>
      '8 продуктов · Самокат · ₽1 054.';

  @override
  String get notificationsAddToListPill => '＋ В список';

  @override
  String get userCreateProfileTitle => 'Как вас зовут?';

  @override
  String get userCreateProfileSubtitle =>
      'Добавьте имя и фото — их увидит партнёр в общем списке.';

  @override
  String get userCreateProfileNameHint => 'Ваше имя';

  @override
  String get userCreateProfileSkip => 'Пропустить';

  @override
  String get userCreateProfileNext => 'Далее';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchHint => 'Продукт или рецепт…';

  @override
  String get searchFilterAll => 'Всё';

  @override
  String get searchFilterVegetables => 'Овощи';

  @override
  String get searchFilterDairy => 'Молочное';

  @override
  String get searchFilterGrocery => 'Бакалея';

  @override
  String get searchFilterRecipes => 'Рецепты';

  @override
  String get searchResults => 'Результаты';

  @override
  String get searchNothingFound => 'Ничего не найдено';

  @override
  String get insightsTitle => 'Инсайты';

  @override
  String get insightsTipKicker => '✨ СОВЕТ PORA';

  @override
  String get insightsTipTitle => 'Вы любите карбонару!';

  @override
  String get insightsTipBody =>
      'Похожий профиль вкуса — попробуйте мак-н-чиз. 4 из 6 ингредиентов у вас уже бывают регулярно.';

  @override
  String get insightsTipAction => 'Открыть рецепт →';

  @override
  String get insightsRunsOutMost => 'Чаще всего заканчивается';

  @override
  String get insightsFavoriteCuisines => 'Любимые кухни';

  @override
  String get insightsCuisineItalian => 'Итальянская';

  @override
  String get insightsCuisinePasta => 'Паста';

  @override
  String get insightsCuisineBreakfasts => 'Завтраки';

  @override
  String get insightsCuisineLight => 'Лёгкое';

  @override
  String get orderTitle => 'Заказ';

  @override
  String get orderCart => 'Корзина';

  @override
  String get orderWhenToDeliver => 'Когда доставить';

  @override
  String orderCheckoutCta(String total) {
    return 'Заказать в Самокате · $total';
  }

  @override
  String get orderSummaryGoods => 'Товары';

  @override
  String get orderSummaryDiscount => 'Скидка −15%';

  @override
  String get orderSummaryDelivery => 'Доставка';

  @override
  String get orderSummaryFree => 'Бесплатно';

  @override
  String get orderSummaryTotal => 'Итого';

  @override
  String get recipeImportTitle => 'Рецепт по ссылке';

  @override
  String get recipePreviewTitle => 'Паста Карбонара';

  @override
  String get recipePreviewMeta => 'eda.ru · 25 мин · 2 порции';

  @override
  String get recipePreviewFound => '6 ингредиентов найдено';

  @override
  String get recipeDedupBanner =>
      '2 совпадения убрали, чтобы не дублировать с вашим списком';

  @override
  String get recipeIngredients => 'Ингредиенты';

  @override
  String get recipeAddToListCta => 'Добавить 4 продукта в список';

  @override
  String get recipeParseButton => 'Разобрать';

  @override
  String get navList => 'Список';

  @override
  String get navPora => 'Пора';

  @override
  String get navOrder => 'Заказ';

  @override
  String get navProfile => 'Профиль';

  @override
  String get familiesTitle => 'Семьи';

  @override
  String get familiesSubtitle => 'Выберите семью, чтобы открыть её список';

  @override
  String get familiesCurrent => 'Текущая';

  @override
  String get familiesCreateOrJoin => '＋ Создать или присоединиться';

  @override
  String get familiesCreateDialog => 'Как назовем семью?';

  @override
  String get tryToUpdate => 'Попробуйте обновить';

  @override
  String get checkOut => 'Проверить';

  @override
  String get settingsMore => 'Углубленные';

  @override
  String get listsYour => 'Ваш личный список';

  @override
  String get human => 'человека';

  @override
  String get products => 'продуктов';

  @override
  String get lists => 'списков';

  @override
  String get update => 'Обновить';

  @override
  String get connectionSuccess => 'Присоединились';

  @override
  String get familiesNoUrgent => 'Нет срочного';

  @override
  String get welcomeBackTitle => 'Вспомнили вас!';

  @override
  String get welcomeBackSubtitle => 'Секунду, открываем ваш список…';

  @override
  String get errorDuringLoading => 'Ошибка при загрузке';

  @override
  String get familyName => 'Имя семьи';

  @override
  String get familiesCreate => 'Создать';

  @override
  String get familiesConnect => 'Присоединиться';

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
  String get themeSection => 'Theme';

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
  String get recipeDupMark => 'already in list';

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
  String get noInternet => 'No internet connection';

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
  String get noGroups => 'No groups yet';

  @override
  String get settingsChangeThemeIOSEasterEgg =>
      '* To change your theme, go to Settings > PORA > Theme\n* Select a new theme from the settings menu\n* Tap on \'Theme\' in the app\'s settings to switch between light and dark modes';
}
