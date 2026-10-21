// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Язык';

  @override
  String get onlyYou => 'Только Вы';

  @override
  String get sendAgainAfter => 'Отправить еще раз через...';

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
  String get authErrorInvalidPhone => 'Неверный телефон или email!';

  @override
  String authPhoneSendOtp(String isPhone) {
    String _temp0 = intl.Intl.selectLogic(isPhone, {
      'true': 'в Telegram!',
      'false': 'на почту!',
      'other': 'куда-то',
    });
    return 'Отправим код $_temp0';
  }

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
      'По вашим покупкам Pora подскажет, что скоро закончится, и напомнит добавить это в список.';

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
  String get listUrgent => 'Срочно';

  @override
  String get listAdd => 'Добавить';

  @override
  String get predictionsAddToList => 'В список';

  @override
  String get predictionsDismiss => 'Не надо';

  @override
  String get itemDetailAddedBy => 'Добавил(а)';

  @override
  String get itemDetailQuantity => 'Количество';

  @override
  String get itemDetailUrgent => 'Срочно';

  @override
  String get itemDetailRemind => 'Напоминать';

  @override
  String get itemDetailMarkBought => 'Отметить купленным';

  @override
  String get itemDetailDelete => 'Удалить из списка';

  @override
  String get addItemQuantity => 'Количество';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppSection => 'Приложение';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsPrivacy => 'Приватность и данные';

  @override
  String get settingsAboutPora => 'О Pora';

  @override
  String get settingsLogout => 'Выйти';

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
  String get searchHint => 'Название продукта…';

  @override
  String get searchNothingFound => 'Ничего не найдено';

  @override
  String get insightsTitle => 'Инсайты';

  @override
  String get recipeImportTitle => 'Рецепт по ссылке';

  @override
  String get recipeIngredients => 'Ингредиенты';

  @override
  String recipeAddToListCta(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Добавить $countString продукта в список';
  }

  @override
  String get recipeParseButton => 'Разобрать';

  @override
  String get navList => 'Список';

  @override
  String get navPora => 'Пора';

  @override
  String get navProfile => 'Профиль';

  @override
  String get familiesTitle => 'Семьи';

  @override
  String get familiesSubtitle => 'Выберите семью, чтобы открыть её список';

  @override
  String get familiesCreateDialog => 'Как назовем семью?';

  @override
  String get tryToUpdate => 'Попробуйте обновить';

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
  String get done => 'Готово';

  @override
  String get errorGeneric => 'Ошибка';

  @override
  String get pushToken => 'Токен push-уведомлений';

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
  String get profileNameUpdate => 'Обновление профиля';

  @override
  String get briefSnackBar => 'Может все-же добавим \nчто-нибудь?';

  @override
  String get noInternet => 'Нет подключения к интернету';

  @override
  String get noInternetButLoadYouLocally =>
      'Нет интернета, но впустим вас и так!';

  @override
  String get groupDeletionTitle => 'Вы уверены, что хотите удалить группу?';

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

  @override
  String get supportMessage => 'Написать письмо в поддержку';

  @override
  String get supportMessageBottomSheetTopDescription =>
      'Ваше сообщение будет отправлено в службу поддержки. Пожалуйста, укажите как можно больше подробностей.';

  @override
  String get supportMessageBottomSheetSendButton => 'Отправить';

  @override
  String get supportMessageBottomSheetUnderButtonText =>
      'Мы ответим как можно скорее на вашу почту Gmail или прямо в приложении!';

  @override
  String get allergen => 'Аллерген';

  @override
  String get predictionsGreeting => 'Ваш день с PORA';

  @override
  String get predictionsGreetingSub => 'Умные подсказки на основе покупок';

  @override
  String get predictionsSectionSoon => 'Скоро закончится';

  @override
  String get predictionsSectionAiSuggests => 'ИИ предлагает';

  @override
  String get refresh => 'Обновить';

  @override
  String get kpiWeek => 'продуктов';

  @override
  String get kpiRecipes => 'часто берёте';

  @override
  String get kpiDaysToRun => 'скоро закончатся';

  @override
  String get fallbackTip1 =>
      'Храните зелень как букет: в стакане с водой, накрыв пакетом — стоит 2 недели.';

  @override
  String get fallbackTip2 =>
      'Соль в тесто добавляйте в конце — она замедляет работу дрожжей.';

  @override
  String get fallbackTip3 =>
      'Чтобы лук не жёгся при резке — подержите его 15 минут в морозилке.';

  @override
  String get fallbackTip4 =>
      'Пересоленный суп спасает сырой картофель: положите на 10 минут, вытащите.';

  @override
  String get fallbackTip5 =>
      'Проверяйте свежесть яиц в воде: тонет — свежее, всплывает — на выброс.';

  @override
  String get fallbackTip6 =>
      'Разогревайте пиццу на сковороде под крышкой — корочка снова хрустит.';

  @override
  String get fallbackTip7 =>
      'Замороженное мясо режется тоньше — за 20 минут до нарезки в морозилку.';

  @override
  String get fallbackTip8 =>
      'Лимон отдаёт больше сока если катать его ладонью по столу перед резкой.';

  @override
  String get fallbackTip9 =>
      'Сахар в томатный соус убирает лишнюю кислоту — щепотки достаточно.';

  @override
  String get fallbackTip10 =>
      'Хлеб в морозилке живёт месяц; тост из замороженного — как свежий.';

  @override
  String get aiTipOfDayLabel => 'СОВЕТ ДНЯ';

  @override
  String get aiTipOfDayTopic => 'сегодня';

  @override
  String get aiCtaTitle => 'Спросить PORA';

  @override
  String get aiCtaSubtitle => 'рецепты · замены · советы';

  @override
  String get chatSheetTitle => 'PORA';

  @override
  String get chatSheetSubtitle => 'спросите про еду, покупки, замены';

  @override
  String get chatEmptyTitle => 'Начните разговор';

  @override
  String get chatEmptyExamplesLabel => 'Примеры вопросов:';

  @override
  String get chatSample1 => 'Что приготовить из курицы и риса?';

  @override
  String get chatSample2 => 'Чем заменить сметану в тесте?';

  @override
  String get chatSample3 => 'Как хранить зелень чтобы не вяла?';

  @override
  String get chatSample4 => 'Рецепт быстрого ужина на 20 минут';

  @override
  String get chatSample5 => 'Как использовать овощи, пока они не испортились?';

  @override
  String get chatSample6 => 'Составь список для 3 простых завтраков';

  @override
  String get chatSample7 => 'Что приготовить на двоих при небольшом бюджете?';

  @override
  String get chatSample8 => 'Сколько хранится готовый рис в холодильнике?';

  @override
  String get chatSample9 => 'Посоветуй вегетарианский ужин с белком';

  @override
  String get chatSample10 => 'Чем заменить сливочное масло в этом рецепте?';

  @override
  String get chatSample11 => 'Составь три ужина из того, что уже есть';

  @override
  String get chatSample12 => 'Что приготовить из остатков за 15 минут?';

  @override
  String get chatSample13 => 'Предложи рецепт без продуктов-аллергенов';

  @override
  String get chatSample14 => 'Как сделать это блюдо дешевле?';

  @override
  String get chatTyping => 'PORA печатает…';

  @override
  String get chatInputHint => 'Спросите что-нибудь…';

  @override
  String get tipTopicHerbs => 'зелень';

  @override
  String get tipTopicBaking => 'выпечка';

  @override
  String get tipTopicSoups => 'супы';

  @override
  String get tipTopicMeat => 'мясо';

  @override
  String get tipTopicFish => 'рыба';

  @override
  String get tipTopicVegetables => 'овощи';

  @override
  String get tipTopicStorage => 'хранение продуктов';

  @override
  String get tipTopicKitchenHacks => 'кухонные лайфхаки';

  @override
  String get tipTopicSpices => 'специи';

  @override
  String get tipTopicDough => 'тесто';

  @override
  String get tipTopicBreakfast => 'завтраки';

  @override
  String get tipTopicDinner => 'ужины';

  @override
  String get tipTopicsSectionTitle => 'Темы советов';

  @override
  String get tipTopicsSectionDescription =>
      'Выберите какие темы совета появляются';

  @override
  String get tipTopicsAddCustom => 'Добавить свою тему';

  @override
  String get tipTopicsCustomLabel => 'Свои темы';

  @override
  String get tipTopicsPredefinedLabel => 'Предустановленные';

  @override
  String get tipTopicsEmpty => 'Ни одной темы не выбрано — совет будет общий';

  @override
  String get insightsChampionKicker => 'ВАШ ЧЕМПИОН';

  @override
  String insightsChampionSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза',
      many: '$count раз',
      few: '$count раза',
      one: '$count раз',
    );
    return 'куплено $_temp0';
  }

  @override
  String insightsStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня подряд',
      many: '$days дней подряд',
      few: '$days дня подряд',
      one: '$days день подряд',
    );
    return '$_temp0';
  }

  @override
  String get insightsStreakSubtitle => 'ведёте список — не сбавляйте';

  @override
  String insightsFreqEvery(int days) {
    return '~раз в $days дн.';
  }

  @override
  String get insightsPopular => 'Часто покупаете';

  @override
  String get insightsStatsProducts => 'продуктов';

  @override
  String get insightsEmpty => 'Пока нет данных — начните добавлять продукты';

  @override
  String get notificationsFilterAll => 'Все';

  @override
  String get notificationsFilterUrgent => 'Срочные';

  @override
  String get notificationsFilterPrediction => 'Предсказания';

  @override
  String get notificationsFilterPromo => 'Промо';

  @override
  String get notificationsFilterOther => 'Прочее';

  @override
  String get notificationsClearAll => 'Очистить все';

  @override
  String get notificationsDelete => 'Удалить';

  @override
  String get notificationsGroupToday => 'Сегодня';

  @override
  String get notificationsGroupYesterday => 'Вчера';

  @override
  String get notificationsEmptyTitle => 'Тишина';

  @override
  String get notificationsEmptyBody => 'Новые уведомления появятся здесь';

  @override
  String get recipeCreateListCta => 'Куда добавить рецепт?';

  @override
  String get offlineWriteBlocked => 'Нет интернета — изменение не сохранится';

  @override
  String get offlineSavedQueued => 'Сохранено. Отправим, когда появится сеть';

  @override
  String offlineSyncDropped(int count) {
    return 'Не синхронизировано изменений: $count';
  }

  @override
  String get offlineReadBanner => 'Работаете офлайн — данные из кэша';

  @override
  String get chatImportRecipeCta => 'Импортировать рецепт';

  @override
  String get listsEmptyTitle => 'Списков у вас пока нет';

  @override
  String get listsEmptySubtitle => 'Может стоит создать новый?';

  @override
  String get aiModelSettingsSection => 'Модель Pora-AI';

  @override
  String get aiConfigRow => 'Своя модель Pora-AI';

  @override
  String get aiConfigRowSubtitle => 'Свой ключ OpenRouter и модели';

  @override
  String get aiConfigTitle => 'Модель Pora-AI';

  @override
  String get aiConfigIntro =>
      'Подключите свой ключ OpenRouter и выберите модели для Pora-AI. Оставьте поле пустым, чтобы использовать значение по умолчанию.';

  @override
  String get aiConfigApiKeyLabel => 'API-ключ OpenRouter';

  @override
  String get aiConfigApiKeyHint => 'sk-or-...';

  @override
  String get aiConfigModelsSection => 'Модели';

  @override
  String get aiConfigPoraModelLabel => 'Модель PORA-AI';

  @override
  String get aiConfigPoraModelHint => 'например, openai/gpt-4o-mini';

  @override
  String get aiConfigTipsModelLabel => 'Модель подсказок (Tips)';

  @override
  String get aiConfigTipsModelHint => 'Пусто — как в приложении';

  @override
  String get aiConfigNeedKeyNote =>
      'Введите API-ключ, чтобы задать свои модели';

  @override
  String get aiConfigReset => 'Сбросить к значениям по умолчанию';

  @override
  String get aiConfigSaved => 'Настройки Pora-AI сохранены';

  @override
  String get aiConfigResetDone =>
      'Восстановлены настройки Pora-AI по умолчанию';

  @override
  String get aiConfigInfoTitle => 'Как подключить свою модель';

  @override
  String get aiConfigInfoBody =>
      '1. Создайте бесплатный аккаунт на openrouter.ai.\n2. Откройте раздел Keys, создайте новый API-ключ и вставьте его сюда.\n3. На странице openrouter.ai/models скопируйте идентификатор модели (например, openai/gpt-4o-mini или anthropic/claude-3.5-sonnet).\n4. Вставьте идентификатор в поле PORA-AI. Поле Tips необязательно — оставьте пустым, чтобы использовать модель приложения по умолчанию с вашим ключом.\n\nКлюч хранится только на этом устройстве и используется только для ваших запросов к Pora-AI.';

  @override
  String get aiConfigInfoClose => 'Понятно';

  @override
  String get supportEmptyError => 'Сначала напишите сообщение';

  @override
  String get supportSent => 'Сообщение отправлено — скоро ответим';

  @override
  String get supportFailed =>
      'Не удалось отправить. Проверьте подключение и повторите';

  @override
  String get supportSheetHint => 'Опишите проблему или пожелание...';

  @override
  String get shortcutAddItem => 'Добавить товар';

  @override
  String importantReminderTitle(String product) {
    return 'Купи $product';
  }

  @override
  String importantReminderFrom(String user) {
    return 'от $user';
  }

  @override
  String get importantReminderBody => 'Отметьте «Куплено», когда купите';

  @override
  String get importantReminderMarkBought => 'Куплено';

  @override
  String get liveActivityTestRow => 'Тест Live Activity';

  @override
  String get liveActivityTestSample => 'Молоко';

  @override
  String get listPickerTitle => 'В какой список добавить?';

  @override
  String get listPickerEmpty => 'Списков пока нет — сначала создайте';

  @override
  String get predictionsAdded => 'Добавлено в список';

  @override
  String get shortcutOpenLists => 'Открыть списки';

  @override
  String get shortcutOpenPora => 'Спросить Pora-AI';

  @override
  String insightsPeriodDays(int days) {
    return '$days дн.';
  }

  @override
  String insightsStreakBest(int days) {
    return 'Рекорд: $days';
  }

  @override
  String get insightsStreakStart => 'Заходите каждый день, чтобы начать серию';

  @override
  String get insightsKpiAdded => 'добавлено';

  @override
  String get insightsKpiBought => 'куплено';

  @override
  String get insightsKpiCompletion => 'добавленного куплено';

  @override
  String get insightsKpiActiveDays => 'активных дней';

  @override
  String get insightsKpiMinutes => 'минут в приложении';

  @override
  String get insightsKpiSessions => 'сессий';

  @override
  String insightsAvgSession(String minutes) {
    return '≈$minutes мин за сессию';
  }

  @override
  String get insightsActivityTitle => 'Добавлено и куплено';

  @override
  String get insightsActivityEmpty => 'За этот период активности пока нет';

  @override
  String get insightsHeatmapTitle => 'Активность за 4 недели';

  @override
  String get insightsLess => 'меньше';

  @override
  String get insightsMore => 'больше';

  @override
  String get insightsRhythmTitle => 'Ваш ритм';

  @override
  String get insightsPartMorning => 'Утро';

  @override
  String get insightsPartAfternoon => 'День';

  @override
  String get insightsPartEvening => 'Вечер';

  @override
  String get insightsPartNight => 'Ночь';

  @override
  String get insightsPeakMorning => 'Чаще всего вы активны утром';

  @override
  String get insightsPeakAfternoon => 'Чаще всего вы активны днём';

  @override
  String get insightsPeakEvening => 'Чаще всего вы активны вечером';

  @override
  String get insightsPeakNight => 'Чаще всего вы активны ночью';

  @override
  String insightsPeakWeekday(String day) {
    return 'Самый активный день — $day';
  }

  @override
  String get insightsCategoriesTitle => 'Что вы добавляете';

  @override
  String get insightsDueSoonTitle => 'Пора докупить';

  @override
  String get insightsDueNow => 'уже пора';

  @override
  String insightsDueInDays(int days) {
    return 'через ~$days дн.';
  }

  @override
  String get insightsTopBoughtTitle => 'Чаще всего покупали за период';

  @override
  String get insightsEngagementTitle => 'Как вы пользуетесь Pora';

  @override
  String get insightsKpiListsOpened => 'открытий списков';

  @override
  String get insightsKpiListsCreated => 'списков создано';

  @override
  String get insightsKpiRecipes => 'рецептов импортировано';

  @override
  String get insightsKpiAi => 'сообщений Pora';

  @override
  String get insightsKpiDeleted => 'удалено позиций';

  @override
  String get insightsAllTimeTitle => 'За всё время';

  @override
  String get insightsKpiReminders => 'с напоминанием';

  @override
  String get insightsKpiUrgent => 'срочных';

  @override
  String get insightsLocalNote =>
      'Статистика пользования считается на этом устройстве';

  @override
  String get insightsNoUsageYet => 'Статистика появится по мере использования';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountBody =>
      'Профиль, личные списки и статистика будут удалены безвозвратно. Общие семейные списки останутся у семьи; если вы владелец семьи, права перейдут самому давнему участнику. Действие нельзя отменить.';

  @override
  String get deleteAccountFailed =>
      'Не удалось удалить аккаунт. Проверьте подключение и попробуйте ещё раз.';

  @override
  String get chatReportAi => 'Пожаловаться';

  @override
  String get chatReportSent => 'Спасибо, мы проверим этот ответ.';

  @override
  String get chatReportFailed =>
      'Не удалось отправить жалобу. Попробуйте позже.';

  @override
  String get aiDisclaimer =>
      'Pora AI может ошибаться. Проверяйте важную информацию.';
}
