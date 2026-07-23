// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'ПОРА';

  @override
  String get language => 'Язык';

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
  String get briefDeletionTitle => 'Вы уверены что хотите удалить продукт?';

  @override
  String get briefAddYourOwn => 'Добавить';

  @override
  String get briefInputProduct => 'Введите продукт или вид';

  @override
  String get briefInputEmoji => 'Введите эмодзи/обозначение для продукта';

  @override
  String get briefAlreadyContains => 'Данный продукт уже выбран';

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
  String get searchHint => 'Название продукта…';

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
  String get showAll => 'Показать все';

  @override
  String get priorityLabel => 'Приоритет';

  @override
  String get everyDay => 'Каждый день';

  @override
  String get newList => 'Новый список';

  @override
  String get listNamePlaceholder => 'Название списка';

  @override
  String get cancel => 'Отмена';

  @override
  String get quantityLabel => 'Кол-во';

  @override
  String get personal => 'Личное';

  @override
  String get notify => 'Уведомить';

  @override
  String get notifyEveryone => 'Всем';

  @override
  String get notifyRecipients => 'Кому';

  @override
  String get notifyAddCustom => 'Добавить имя';

  @override
  String get notifyMessageLabel => 'Сообщение';

  @override
  String notifyHint(String itemName) {
    return 'Срочно купи $itemName';
  }

  @override
  String get notifySend => 'Отправить';

  @override
  String get notifySent => 'Уведомление отправлено';

  @override
  String get advancedSettings => 'Расширенные настройки';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get themeSection => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get notificationsPermission => 'Разрешения на уведомления';

  @override
  String get granted => 'Разрешено';

  @override
  String get denied => 'Запрещено';

  @override
  String get notDetermined => 'Не запрошено';

  @override
  String get requestPermission => 'Запросить';

  @override
  String get confirmations => 'Подтверждения';

  @override
  String get askBeforeDelete => 'Спрашивать перед удалением';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get deleteItemTitle => 'Удалить продукт?';

  @override
  String get deleteItemBody => 'Действие нельзя отменить.';

  @override
  String get dontAskAgain => 'Не спрашивать снова';

  @override
  String get delete => 'Удалить';

  @override
  String get returnToList => 'Вернуть в список';

  @override
  String get nooneToNotify => 'Некого уведомлять';

  @override
  String get notFound => 'Не найдено';

  @override
  String get recipeEmptyHint =>
      'Вставьте ссылку на рецепт и нажмите «Разобрать»';

  @override
  String get recipeDupMark => 'уже в списке';

  @override
  String get done => 'Готово';

  @override
  String get errorGeneric => 'Ошибка';

  @override
  String get pushToken => 'Push-токен';

  @override
  String get resync => 'Синхронизировать';

  @override
  String get tokenSynced => 'Токен отправлен';

  @override
  String get deleteListTitle => 'Удалить список?';

  @override
  String deleteListBody(String listName) {
    return 'Список «$listName» и все продукты в нём будут удалены. Действие нельзя отменить.';
  }

  @override
  String get membersScreenTitle => 'Участники';

  @override
  String get owner => 'Владелец';

  @override
  String get member => 'Участник';

  @override
  String get addProduct => 'Добавить продукт';

  @override
  String get productName => 'Название';

  @override
  String get section => 'Раздел';

  @override
  String get unit => 'Единица';

  @override
  String get priorityHigh => 'Высокий';

  @override
  String get priorityMed => 'Средний';

  @override
  String get priorityLow => 'Низкий';

  @override
  String get urgent => 'Срочно';

  @override
  String get remindEvery => 'Напоминать каждые';

  @override
  String get days => 'дн.';

  @override
  String get customValue => 'Своё…';

  @override
  String get save => 'Сохранить';

  @override
  String addedByName(String name) {
    return 'Добавил(а): $name';
  }

  @override
  String get splashLoadingSlow => 'Уже почти загрузились…';

  @override
  String get splashLoadingVerySlow => 'Всё ещё грузимся… проверяем связь';

  @override
  String get noInternet => 'Нет подключения к интернету';

  @override
  String get noInternetButLoadYouLocally =>
      'Нет интернета, но впустим вас и так!';

  @override
  String get retry => 'Обновить';

  @override
  String get groupsTitle => 'Ваши группы';

  @override
  String get groupsSubtitle =>
      'Список равен группе. Пригласите людей — они увидят список.';

  @override
  String get groupCreate => 'Создать группу';

  @override
  String get groupConnect => 'Присоединиться';

  @override
  String get groupNameHint => 'Название группы';

  @override
  String get groupPersonal => 'Личная';

  @override
  String get groupShared => 'Общая';

  @override
  String get noGroups => 'Пока нет ни одной группы';

  @override
  String get settingsChangeThemeIOSEasterEgg =>
      '* To change your theme, go to Settings > PORA > Theme\n* Select a new theme from the settings menu\n* Tap on \'Theme\' in the app\'s settings to switch between light and dark modes';

  @override
  String get tutorialTitle => 'Как это работает';

  @override
  String get tutorialSkip => 'Пропустить';

  @override
  String get tutorialNext => 'Далее';

  @override
  String get tutorialDone => 'Начать';

  @override
  String get tutorialInviteTitle => 'Пригласите близких';

  @override
  String get tutorialInviteBody =>
      'Свайп группы вправо → «Пригласить». Партнёр видит тот же список.';

  @override
  String get tutorialAddTitle => 'Добавить продукт';

  @override
  String get tutorialAddBody =>
      'Кнопка «+» внизу списка. Название, количество, раздел, приоритет — и готово.';

  @override
  String get tutorialEditTitle => 'Изменить и отметить';

  @override
  String get tutorialEditBody =>
      'Тап по чекбоксу — куплено. Тап по строке — детали и правки.';

  @override
  String get tutorialDeleteTitle => 'Удалить';

  @override
  String get tutorialDeleteBody =>
      'Свайп продукта влево → «Удалить». Диалог подтверждения — можно отключить.';

  @override
  String get tutorialAiTitle => 'Импорт рецепта';

  @override
  String get tutorialAiBody =>
      'Ссылку на рецепт — в поле, «Разобрать». Ингредиенты падают в список, дубли отмечаются.';

  @override
  String get tutorialSettingsTitle => 'Всё под рукой';

  @override
  String get tutorialSettingsBody =>
      'Тема, язык, уведомления и подтверждения — в «Профиль → Расширенные настройки».';

  @override
  String get showTutorial => 'Показать туториал';

  @override
  String get tutorialSampleGroupFamily => 'Семья';

  @override
  String get tutorialSampleMilk => 'Молоко';

  @override
  String get tutorialSampleBread => 'Хлеб';

  @override
  String get tutorialSampleAvocado => 'Авокадо';

  @override
  String get tutorialSampleMilkQty => 'Молоко 2×1л';

  @override
  String get tutorialSampleCoffee => 'Кофе';

  @override
  String get tutorialSampleCola => 'Кола';

  @override
  String get tutorialSampleRecipeUrl => 'recipe.example/pasta';

  @override
  String get tutorialSampleIngredient1 => 'Спагетти 400 г';

  @override
  String get tutorialSampleIngredient2 => 'Помидоры 500 г';

  @override
  String get tutorialSampleIngredient3 => 'Чеснок 3 зубчика';

  @override
  String get tutorialSampleToggleTheme => 'Тема';

  @override
  String get tutorialSampleToggleNotif => 'Уведомления';

  @override
  String get tutorialSampleToggleConfirm => 'Подтверждение';

  @override
  String get tutorialConnectTitle => 'Присоединиться по коду';

  @override
  String get tutorialConnectBody =>
      'Партнёр даёт ссылку или код. Вставьте — попадаете в общий список.';

  @override
  String get tutorialNotifyTitle => 'Пинг «срочно нужно»';

  @override
  String get tutorialNotifyBody =>
      'Тап «!» на продукте — партнёру прилетит push «срочно купи». Без звонков.';

  @override
  String get tutorialOutroTitle => 'А с остальным разберётесь сами';

  @override
  String get tutorialOutroBody =>
      'Тыкайте, свайпайте, ошибайтесь — приложение прощает почти всё.';

  @override
  String get tutorialSampleInviteCode => 'PORA-4F72';

  @override
  String get tutorialSamplePushSender => 'Аня';

  @override
  String get tutorialSamplePushBody => 'Срочно нужно молоко';

  @override
  String get tutorialSampleInviteMessage => 'Присоединяйся к списку';
}
