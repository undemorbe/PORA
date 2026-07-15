import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('ru'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Pora'**
  String get appName;

  /// The language of the application
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// The first line under the app name
  ///
  /// In en, this message translates to:
  /// **'Общий список для пар и семей'**
  String get authUnderAppName1;

  /// The second line under the app name
  ///
  /// In en, this message translates to:
  /// **'Рецепты, дом и доставка — в одном месте'**
  String get authUnderAppName2;

  /// The sign in with other methods title
  ///
  /// In en, this message translates to:
  /// **'Войти иным способом'**
  String get authSignInExpansibleExpand;

  /// The sign in with other methods title
  ///
  /// In en, this message translates to:
  /// **'Свернуть'**
  String get authSignInExpansibleCollapse;

  /// The sign in with email button text
  ///
  /// In en, this message translates to:
  /// **'Войти через email'**
  String get authSignInWithEmail;

  /// The sign in with Google button text
  ///
  /// In en, this message translates to:
  /// **'Войти через Google'**
  String get authSignInWithGoogle;

  /// The sign in with Apple button text
  ///
  /// In en, this message translates to:
  /// **'Войти через Apple'**
  String get authSignInWithApple;

  /// The sign in with Phone button text
  ///
  /// In en, this message translates to:
  /// **'Войти через телефон'**
  String get authSignInWithPhone;

  /// The private policy link text
  ///
  /// In en, this message translates to:
  /// **'Продолжая, вы соглашаетесь с\nУсловиями и Политикой конфиденциальности'**
  String get authPrivatePolicy;

  /// authTitle
  ///
  /// In en, this message translates to:
  /// **'Почти с нами'**
  String get authTitle;

  /// authSubtitle
  ///
  /// In en, this message translates to:
  /// **'Введите номер телефона или почту — пришлём код для входа.'**
  String get authSubtitle;

  /// authSubtitle2
  ///
  /// In en, this message translates to:
  /// **'Начните вводить, сами определим, телефон это или почта.'**
  String get authSubtitle2;

  /// authJoinButton
  ///
  /// In en, this message translates to:
  /// **'Присоединиться'**
  String get authJoinButton;

  /// userCreateProfileNameRequired
  ///
  /// In en, this message translates to:
  /// **'Может все-же скажете имя?'**
  String get userCreateProfileNameRequired;

  /// commonError
  ///
  /// In en, this message translates to:
  /// **'Ошибка'**
  String get commonError;

  /// otpTitle
  ///
  /// In en, this message translates to:
  /// **'Осталось немного!'**
  String get otpTitle;

  /// otpEnterCodeSentTo
  ///
  /// In en, this message translates to:
  /// **'Введите код отправленный на '**
  String get otpEnterCodeSentTo;

  /// otpResendQuestion
  ///
  /// In en, this message translates to:
  /// **'Не получили код?'**
  String get otpResendQuestion;

  /// otpResend
  ///
  /// In en, this message translates to:
  /// **'Отправить еще раз'**
  String get otpResend;

  /// otpVerifyButton
  ///
  /// In en, this message translates to:
  /// **'Проверить код'**
  String get otpVerifyButton;

  /// otpValidationLength
  ///
  /// In en, this message translates to:
  /// **'Введите 6-значный код'**
  String get otpValidationLength;

  /// otpValidationDigits
  ///
  /// In en, this message translates to:
  /// **'Код состоит только из цифр'**
  String get otpValidationDigits;

  /// authSwitchToEmail
  ///
  /// In en, this message translates to:
  /// **'Войти по почте'**
  String get authSwitchToEmail;

  /// authSwitchToPhone
  ///
  /// In en, this message translates to:
  /// **'Войти по телефону'**
  String get authSwitchToPhone;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Шаг {step} из {total}'**
  String onboardingStep(int step, int total);

  /// onboardingSlide1Title
  ///
  /// In en, this message translates to:
  /// **'Рецепт → список\nза секунды'**
  String get onboardingSlide1Title;

  /// onboardingSlide1Body
  ///
  /// In en, this message translates to:
  /// **'Киньте ссылку на рецепт — Pora соберёт ингредиенты и уберёт то, что уже есть.'**
  String get onboardingSlide1Body;

  /// onboardingSlide2Title
  ///
  /// In en, this message translates to:
  /// **'Один список\nна двоих'**
  String get onboardingSlide2Title;

  /// onboardingSlide2Body
  ///
  /// In en, this message translates to:
  /// **'Добавляйте вместе — видно, кто что внёс. Партнёр захватит нужное по дороге домой.'**
  String get onboardingSlide2Body;

  /// onboardingSlide3Title
  ///
  /// In en, this message translates to:
  /// **'Pora знает,\nкогда пора'**
  String get onboardingSlide3Title;

  /// onboardingSlide3Body
  ///
  /// In en, this message translates to:
  /// **'По вашим покупкам подскажет, что скоро закончится, и закажет в один тап.'**
  String get onboardingSlide3Body;

  /// onboardingSkip
  ///
  /// In en, this message translates to:
  /// **'Пропустить'**
  String get onboardingSkip;

  /// onboardingStart
  ///
  /// In en, this message translates to:
  /// **'Начать'**
  String get onboardingStart;

  /// onboardingNext
  ///
  /// In en, this message translates to:
  /// **'Далее'**
  String get onboardingNext;

  /// splashTagline
  ///
  /// In en, this message translates to:
  /// **'Список, который помнит за вас'**
  String get splashTagline;

  /// briefTitle
  ///
  /// In en, this message translates to:
  /// **'Что у вас часто заканчивается?'**
  String get briefTitle;

  /// briefSubtitle
  ///
  /// In en, this message translates to:
  /// **'Отметьте продукты — Pora напомнит вовремя. Это можно пропустить.'**
  String get briefSubtitle;

  /// briefSkip
  ///
  /// In en, this message translates to:
  /// **'Пропустить'**
  String get briefSkip;

  /// briefNext
  ///
  /// In en, this message translates to:
  /// **'Далее'**
  String get briefNext;

  /// briefItemMilk
  ///
  /// In en, this message translates to:
  /// **'Молоко'**
  String get briefItemMilk;

  /// briefItemBread
  ///
  /// In en, this message translates to:
  /// **'Хлеб'**
  String get briefItemBread;

  /// briefItemEggs
  ///
  /// In en, this message translates to:
  /// **'Яйца'**
  String get briefItemEggs;

  /// briefItemCoffee
  ///
  /// In en, this message translates to:
  /// **'Кофе'**
  String get briefItemCoffee;

  /// briefItemCheese
  ///
  /// In en, this message translates to:
  /// **'Сыр'**
  String get briefItemCheese;

  /// briefItemBananas
  ///
  /// In en, this message translates to:
  /// **'Бананы'**
  String get briefItemBananas;

  /// briefItemButter
  ///
  /// In en, this message translates to:
  /// **'Масло'**
  String get briefItemButter;

  /// briefItemWater
  ///
  /// In en, this message translates to:
  /// **'Вода'**
  String get briefItemWater;

  /// briefItemVegetables
  ///
  /// In en, this message translates to:
  /// **'Овощи'**
  String get briefItemVegetables;

  /// briefItemTomatoes
  ///
  /// In en, this message translates to:
  /// **'Помидоры'**
  String get briefItemTomatoes;

  /// briefItemPasta
  ///
  /// In en, this message translates to:
  /// **'Паста'**
  String get briefItemPasta;

  /// briefItemChicken
  ///
  /// In en, this message translates to:
  /// **'Курица'**
  String get briefItemChicken;

  /// listTitle
  ///
  /// In en, this message translates to:
  /// **'Наш список'**
  String get listTitle;

  /// listMembersCount
  ///
  /// In en, this message translates to:
  /// **'2 человека · 8 продуктов'**
  String get listMembersCount;

  /// listUrgent
  ///
  /// In en, this message translates to:
  /// **'Срочно'**
  String get listUrgent;

  /// listAdd
  ///
  /// In en, this message translates to:
  /// **'Добавить'**
  String get listAdd;

  /// predictionsTitle
  ///
  /// In en, this message translates to:
  /// **'Пора докупить'**
  String get predictionsTitle;

  /// predictionsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Скоро закончится — по вашим покупкам'**
  String get predictionsSubtitle;

  /// predictionsOrderTitle
  ///
  /// In en, this message translates to:
  /// **'Заказать всё в один тап'**
  String get predictionsOrderTitle;

  /// predictionsOrderSubtitle
  ///
  /// In en, this message translates to:
  /// **'Самокат · доставка за 15 минут'**
  String get predictionsOrderSubtitle;

  /// predictionsOrderDiscount
  ///
  /// In en, this message translates to:
  /// **'−15% на первый заказ'**
  String get predictionsOrderDiscount;

  /// predictionsAddToList
  ///
  /// In en, this message translates to:
  /// **'В список'**
  String get predictionsAddToList;

  /// predictionsDismiss
  ///
  /// In en, this message translates to:
  /// **'Не надо'**
  String get predictionsDismiss;

  /// itemDetailName
  ///
  /// In en, this message translates to:
  /// **'Молоко'**
  String get itemDetailName;

  /// itemDetailSubtitle
  ///
  /// In en, this message translates to:
  /// **'2 л · Молочное'**
  String get itemDetailSubtitle;

  /// itemDetailAddedBy
  ///
  /// In en, this message translates to:
  /// **'Добавил(а)'**
  String get itemDetailAddedBy;

  /// itemDetailSection
  ///
  /// In en, this message translates to:
  /// **'Раздел'**
  String get itemDetailSection;

  /// itemDetailSectionValue
  ///
  /// In en, this message translates to:
  /// **'Молочное'**
  String get itemDetailSectionValue;

  /// itemDetailQuantity
  ///
  /// In en, this message translates to:
  /// **'Количество'**
  String get itemDetailQuantity;

  /// itemDetailQuantityValue
  ///
  /// In en, this message translates to:
  /// **'2 л'**
  String get itemDetailQuantityValue;

  /// itemDetailUrgent
  ///
  /// In en, this message translates to:
  /// **'Срочно'**
  String get itemDetailUrgent;

  /// itemDetailRemind
  ///
  /// In en, this message translates to:
  /// **'Напоминать'**
  String get itemDetailRemind;

  /// itemDetailRemindEvery
  ///
  /// In en, this message translates to:
  /// **'Каждые 7 дней'**
  String get itemDetailRemindEvery;

  /// itemDetailInsight
  ///
  /// In en, this message translates to:
  /// **'Покупаете ~раз в 7 дней · последний раз 6 дней назад. Скоро предложу докупить.'**
  String get itemDetailInsight;

  /// itemDetailMarkBought
  ///
  /// In en, this message translates to:
  /// **'Отметить купленным'**
  String get itemDetailMarkBought;

  /// itemDetailDelete
  ///
  /// In en, this message translates to:
  /// **'Удалить из списка'**
  String get itemDetailDelete;

  /// addItemTitle
  ///
  /// In en, this message translates to:
  /// **'Добавить продукт'**
  String get addItemTitle;

  /// addItemExampleValue
  ///
  /// In en, this message translates to:
  /// **'Авокадо'**
  String get addItemExampleValue;

  /// addItemNameHint
  ///
  /// In en, this message translates to:
  /// **'Название продукта'**
  String get addItemNameHint;

  /// addItemQuantity
  ///
  /// In en, this message translates to:
  /// **'Количество'**
  String get addItemQuantity;

  /// addItemSection
  ///
  /// In en, this message translates to:
  /// **'Раздел'**
  String get addItemSection;

  /// addItemUrgent
  ///
  /// In en, this message translates to:
  /// **'Срочно'**
  String get addItemUrgent;

  /// addItemUrgentSubtitle
  ///
  /// In en, this message translates to:
  /// **'Нужно купить сегодня'**
  String get addItemUrgentSubtitle;

  /// addItemRemind
  ///
  /// In en, this message translates to:
  /// **'Напоминать регулярно'**
  String get addItemRemind;

  /// addItemRemindEvery
  ///
  /// In en, this message translates to:
  /// **'Каждые 7 дней'**
  String get addItemRemindEvery;

  /// addItemSubmit
  ///
  /// In en, this message translates to:
  /// **'Добавить в список'**
  String get addItemSubmit;

  /// settingsTitle
  ///
  /// In en, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// settingsHouseholdSection
  ///
  /// In en, this message translates to:
  /// **'Хозяйство'**
  String get settingsHouseholdSection;

  /// settingsAppSection
  ///
  /// In en, this message translates to:
  /// **'Приложение'**
  String get settingsAppSection;

  /// settingsNotifications
  ///
  /// In en, this message translates to:
  /// **'Уведомления'**
  String get settingsNotifications;

  /// settingsDelivery
  ///
  /// In en, this message translates to:
  /// **'Доставка'**
  String get settingsDelivery;

  /// settingsProAd
  ///
  /// In en, this message translates to:
  /// **'Pora+ · без рекламы'**
  String get settingsProAd;

  /// settingsTryPill
  ///
  /// In en, this message translates to:
  /// **'Попробовать'**
  String get settingsTryPill;

  /// settingsPrivacy
  ///
  /// In en, this message translates to:
  /// **'Приватность и данные'**
  String get settingsPrivacy;

  /// settingsAboutPora
  ///
  /// In en, this message translates to:
  /// **'О Pora'**
  String get settingsAboutPora;

  /// settingsLogout
  ///
  /// In en, this message translates to:
  /// **'Выйти'**
  String get settingsLogout;

  /// settingsMembersNames
  ///
  /// In en, this message translates to:
  /// **'Борис и Анна'**
  String get settingsMembersNames;

  /// settingsInvitePill
  ///
  /// In en, this message translates to:
  /// **'Пригласить'**
  String get settingsInvitePill;

  /// householdInviteTitle
  ///
  /// In en, this message translates to:
  /// **'Пригласить партнёра'**
  String get householdInviteTitle;

  /// householdCookTogether
  ///
  /// In en, this message translates to:
  /// **'Готовьте вместе'**
  String get householdCookTogether;

  /// householdInviteDescription
  ///
  /// In en, this message translates to:
  /// **'Pora работает лучше вдвоём. Пригласите партнёра — список и напоминания станут общими.'**
  String get householdInviteDescription;

  /// householdShareLink
  ///
  /// In en, this message translates to:
  /// **'Поделиться ссылкой'**
  String get householdShareLink;

  /// householdShowQr
  ///
  /// In en, this message translates to:
  /// **'Показать QR-код'**
  String get householdShowQr;

  /// householdConnectToFamily
  ///
  /// In en, this message translates to:
  /// **'Подключиться к семье'**
  String get householdConnectToFamily;

  /// householdInviteDescriptionWhenConnecting
  ///
  /// In en, this message translates to:
  /// **'Определили код приглашения, но вы и сами можете его ввести, если мы ошиблись'**
  String get householdInviteDescriptionWhenConnecting;

  /// householdGotInvited
  ///
  /// In en, this message translates to:
  /// **'Вас пригласили в семью'**
  String get householdGotInvited;

  /// householdWriteCode
  ///
  /// In en, this message translates to:
  /// **'Введите код приглашения'**
  String get householdWriteCode;

  /// householdDoLater
  ///
  /// In en, this message translates to:
  /// **'Сделаю позже'**
  String get householdDoLater;

  /// householdCopyCode
  ///
  /// In en, this message translates to:
  /// **'Скопировали в буфер обмена!'**
  String get householdCopyCode;

  /// householdInviteCodeLabel
  ///
  /// In en, this message translates to:
  /// **'Код приглашения'**
  String get householdInviteCodeLabel;

  /// householdCopyPill
  ///
  /// In en, this message translates to:
  /// **'Копировать'**
  String get householdCopyPill;

  /// notificationsTitle
  ///
  /// In en, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// notificationsReadAll
  ///
  /// In en, this message translates to:
  /// **'Прочитать все'**
  String get notificationsReadAll;

  /// notificationsMilkTitle
  ///
  /// In en, this message translates to:
  /// **'По дороге домой захвати молоко'**
  String get notificationsMilkTitle;

  /// notificationsMilkBody
  ///
  /// In en, this message translates to:
  /// **'Оно кончилось — Анна отметила 10 минут назад.'**
  String get notificationsMilkBody;

  /// notificationsMilkTime
  ///
  /// In en, this message translates to:
  /// **'5 минут назад'**
  String get notificationsMilkTime;

  /// notificationsCoffeeTitle
  ///
  /// In en, this message translates to:
  /// **'Скоро закончится кофе'**
  String get notificationsCoffeeTitle;

  /// notificationsCoffeeBody
  ///
  /// In en, this message translates to:
  /// **'Покупаете ~раз в 14 дней, прошло 12.'**
  String get notificationsCoffeeBody;

  /// notificationsPartnerAddedTitle
  ///
  /// In en, this message translates to:
  /// **'Анна добавила 2 продукта'**
  String get notificationsPartnerAddedTitle;

  /// notificationsPartnerAddedBody
  ///
  /// In en, this message translates to:
  /// **'Бананы и Хлеб — в общем списке.'**
  String get notificationsPartnerAddedBody;

  /// notificationsPartnerAddedTime
  ///
  /// In en, this message translates to:
  /// **'Сегодня, 9:12'**
  String get notificationsPartnerAddedTime;

  /// notificationsPromoTitle
  ///
  /// In en, this message translates to:
  /// **'−15% на первый заказ в Самокате'**
  String get notificationsPromoTitle;

  /// notificationsPromoBody
  ///
  /// In en, this message translates to:
  /// **'Промо активно ещё 6 дней.'**
  String get notificationsPromoBody;

  /// notificationsPromoTime
  ///
  /// In en, this message translates to:
  /// **'Вчера'**
  String get notificationsPromoTime;

  /// notificationsOrderDeliveredTitle
  ///
  /// In en, this message translates to:
  /// **'Заказ доставлен'**
  String get notificationsOrderDeliveredTitle;

  /// notificationsOrderDeliveredBody
  ///
  /// In en, this message translates to:
  /// **'8 продуктов · Самокат · ₽1 054.'**
  String get notificationsOrderDeliveredBody;

  /// notificationsAddToListPill
  ///
  /// In en, this message translates to:
  /// **'＋ В список'**
  String get notificationsAddToListPill;

  /// userCreateProfileTitle
  ///
  /// In en, this message translates to:
  /// **'Как вас зовут?'**
  String get userCreateProfileTitle;

  /// userCreateProfileSubtitle
  ///
  /// In en, this message translates to:
  /// **'Добавьте имя и фото — их увидит партнёр в общем списке.'**
  String get userCreateProfileSubtitle;

  /// userCreateProfileNameHint
  ///
  /// In en, this message translates to:
  /// **'Ваше имя'**
  String get userCreateProfileNameHint;

  /// userCreateProfileSkip
  ///
  /// In en, this message translates to:
  /// **'Пропустить'**
  String get userCreateProfileSkip;

  /// userCreateProfileNext
  ///
  /// In en, this message translates to:
  /// **'Далее'**
  String get userCreateProfileNext;

  /// searchTitle
  ///
  /// In en, this message translates to:
  /// **'Поиск'**
  String get searchTitle;

  /// searchHint
  ///
  /// In en, this message translates to:
  /// **'Продукт или рецепт…'**
  String get searchHint;

  /// searchFilterAll
  ///
  /// In en, this message translates to:
  /// **'Всё'**
  String get searchFilterAll;

  /// searchFilterVegetables
  ///
  /// In en, this message translates to:
  /// **'Овощи'**
  String get searchFilterVegetables;

  /// searchFilterDairy
  ///
  /// In en, this message translates to:
  /// **'Молочное'**
  String get searchFilterDairy;

  /// searchFilterGrocery
  ///
  /// In en, this message translates to:
  /// **'Бакалея'**
  String get searchFilterGrocery;

  /// searchFilterRecipes
  ///
  /// In en, this message translates to:
  /// **'Рецепты'**
  String get searchFilterRecipes;

  /// searchResults
  ///
  /// In en, this message translates to:
  /// **'Результаты'**
  String get searchResults;

  /// searchNothingFound
  ///
  /// In en, this message translates to:
  /// **'Ничего не найдено'**
  String get searchNothingFound;

  /// insightsTitle
  ///
  /// In en, this message translates to:
  /// **'Инсайты'**
  String get insightsTitle;

  /// insightsTipKicker
  ///
  /// In en, this message translates to:
  /// **'✨ СОВЕТ PORA'**
  String get insightsTipKicker;

  /// insightsTipTitle
  ///
  /// In en, this message translates to:
  /// **'Вы любите карбонару!'**
  String get insightsTipTitle;

  /// insightsTipBody
  ///
  /// In en, this message translates to:
  /// **'Похожий профиль вкуса — попробуйте мак-н-чиз. 4 из 6 ингредиентов у вас уже бывают регулярно.'**
  String get insightsTipBody;

  /// insightsTipAction
  ///
  /// In en, this message translates to:
  /// **'Открыть рецепт →'**
  String get insightsTipAction;

  /// insightsRunsOutMost
  ///
  /// In en, this message translates to:
  /// **'Чаще всего заканчивается'**
  String get insightsRunsOutMost;

  /// insightsFavoriteCuisines
  ///
  /// In en, this message translates to:
  /// **'Любимые кухни'**
  String get insightsFavoriteCuisines;

  /// insightsCuisineItalian
  ///
  /// In en, this message translates to:
  /// **'Итальянская'**
  String get insightsCuisineItalian;

  /// insightsCuisinePasta
  ///
  /// In en, this message translates to:
  /// **'Паста'**
  String get insightsCuisinePasta;

  /// insightsCuisineBreakfasts
  ///
  /// In en, this message translates to:
  /// **'Завтраки'**
  String get insightsCuisineBreakfasts;

  /// insightsCuisineLight
  ///
  /// In en, this message translates to:
  /// **'Лёгкое'**
  String get insightsCuisineLight;

  /// orderTitle
  ///
  /// In en, this message translates to:
  /// **'Заказ'**
  String get orderTitle;

  /// orderCart
  ///
  /// In en, this message translates to:
  /// **'Корзина'**
  String get orderCart;

  /// orderWhenToDeliver
  ///
  /// In en, this message translates to:
  /// **'Когда доставить'**
  String get orderWhenToDeliver;

  /// No description provided for @orderCheckoutCta.
  ///
  /// In en, this message translates to:
  /// **'Заказать в Самокате · {total}'**
  String orderCheckoutCta(String total);

  /// orderSummaryGoods
  ///
  /// In en, this message translates to:
  /// **'Товары'**
  String get orderSummaryGoods;

  /// orderSummaryDiscount
  ///
  /// In en, this message translates to:
  /// **'Скидка −15%'**
  String get orderSummaryDiscount;

  /// orderSummaryDelivery
  ///
  /// In en, this message translates to:
  /// **'Доставка'**
  String get orderSummaryDelivery;

  /// orderSummaryFree
  ///
  /// In en, this message translates to:
  /// **'Бесплатно'**
  String get orderSummaryFree;

  /// orderSummaryTotal
  ///
  /// In en, this message translates to:
  /// **'Итого'**
  String get orderSummaryTotal;

  /// recipeImportTitle
  ///
  /// In en, this message translates to:
  /// **'Рецепт по ссылке'**
  String get recipeImportTitle;

  /// recipePreviewTitle
  ///
  /// In en, this message translates to:
  /// **'Паста Карбонара'**
  String get recipePreviewTitle;

  /// recipePreviewMeta
  ///
  /// In en, this message translates to:
  /// **'eda.ru · 25 мин · 2 порции'**
  String get recipePreviewMeta;

  /// recipePreviewFound
  ///
  /// In en, this message translates to:
  /// **'6 ингредиентов найдено'**
  String get recipePreviewFound;

  /// recipeDedupBanner
  ///
  /// In en, this message translates to:
  /// **'2 совпадения убрали, чтобы не дублировать с вашим списком'**
  String get recipeDedupBanner;

  /// recipeIngredients
  ///
  /// In en, this message translates to:
  /// **'Ингредиенты'**
  String get recipeIngredients;

  /// recipeAddToListCta
  ///
  /// In en, this message translates to:
  /// **'Добавить 4 продукта в список'**
  String get recipeAddToListCta;

  /// recipeParseButton
  ///
  /// In en, this message translates to:
  /// **'Разобрать'**
  String get recipeParseButton;

  /// navList
  ///
  /// In en, this message translates to:
  /// **'Список'**
  String get navList;

  /// navPora
  ///
  /// In en, this message translates to:
  /// **'Пора'**
  String get navPora;

  /// navOrder
  ///
  /// In en, this message translates to:
  /// **'Заказ'**
  String get navOrder;

  /// navProfile
  ///
  /// In en, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// familiesTitle
  ///
  /// In en, this message translates to:
  /// **'Семьи'**
  String get familiesTitle;

  /// familiesSubtitle
  ///
  /// In en, this message translates to:
  /// **'Выберите семью, чтобы открыть её список'**
  String get familiesSubtitle;

  /// familiesCurrent
  ///
  /// In en, this message translates to:
  /// **'Текущая'**
  String get familiesCurrent;

  /// familiesCreateOrJoin
  ///
  /// In en, this message translates to:
  /// **'＋ Создать или присоединиться'**
  String get familiesCreateOrJoin;

  /// familiesCreateDialog
  ///
  /// In en, this message translates to:
  /// **'Как назовем семью?'**
  String get familiesCreateDialog;

  /// tryToUpdate
  ///
  /// In en, this message translates to:
  /// **'Попробуйте обновить'**
  String get tryToUpdate;

  /// checkOut
  ///
  /// In en, this message translates to:
  /// **'Проверить'**
  String get checkOut;

  /// settingsMore
  ///
  /// In en, this message translates to:
  /// **'Углубленные'**
  String get settingsMore;

  /// listsYour
  ///
  /// In en, this message translates to:
  /// **'Ваш личный список'**
  String get listsYour;

  /// human
  ///
  /// In en, this message translates to:
  /// **'человека'**
  String get human;

  /// products
  ///
  /// In en, this message translates to:
  /// **'продуктов'**
  String get products;

  /// lists
  ///
  /// In en, this message translates to:
  /// **'списков'**
  String get lists;

  /// connectionSuccess
  ///
  /// In en, this message translates to:
  /// **'Присоединились'**
  String get connectionSuccess;

  /// familiesNoUrgent
  ///
  /// In en, this message translates to:
  /// **'Нет срочного'**
  String get familiesNoUrgent;

  /// welcomeBackTitle
  ///
  /// In en, this message translates to:
  /// **'Вспомнили вас!'**
  String get welcomeBackTitle;

  /// welcomeBackSubtitle
  ///
  /// In en, this message translates to:
  /// **'Секунду, открываем ваш список…'**
  String get welcomeBackSubtitle;

  /// errorDuringLoading
  ///
  /// In en, this message translates to:
  /// **'Ошибка при загрузке'**
  String get errorDuringLoading;

  /// nameOfFamily
  ///
  /// In en, this message translates to:
  /// **'Имя семьи'**
  String get familyName;

  /// createButton
  ///
  /// In en, this message translates to:
  /// **'Создать'**
  String get familiesCreate;

  /// connectButton
  ///
  /// In en, this message translates to:
  /// **'Присоединиться'**
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
