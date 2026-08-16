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

  /// language
  ///
  /// In en, this message translates to:
  /// **'Language'**
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

  /// The sign in with other methods title
  ///
  /// In en, this message translates to:
  /// **'Отправить еще раз через...'**
  String get sendAgainAfter;

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

  /// briefDeletionTitle
  ///
  /// In en, this message translates to:
  /// **'Вы уверены что хотите удалить продукт?'**
  String get briefDeletionTitle;

  /// briefAddYourOwn
  ///
  /// In en, this message translates to:
  /// **'Добавить'**
  String get briefAddYourOwn;

  /// briefInputProduct
  ///
  /// In en, this message translates to:
  /// **'Введите продукт или вид'**
  String get briefInputProduct;

  /// briefInputEmoji
  ///
  /// In en, this message translates to:
  /// **'Введите эмодзи/обозначение для продукта'**
  String get briefInputEmoji;

  /// briefAlreadyContains
  ///
  /// In en, this message translates to:
  /// **'Данный продукт уже выбран'**
  String get briefAlreadyContains;

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
  /// **'Пора поможет!'**
  String get predictionsTitle;

  /// predictionsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Скоро закончится — по вашим покупкам'**
  String get predictionsSubtitle;

  /// predictionTip
  ///
  /// In en, this message translates to:
  /// **'Малюсенький советик'**
  String get predictionTip;

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

  /// update
  ///
  /// In en, this message translates to:
  /// **'Обновить'**
  String get update;

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

  /// themeSection
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSection;

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

  /// recipeDupMark
  ///
  /// In en, this message translates to:
  /// **'already in list'**
  String get recipeDupMark;

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

  /// noGroups
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroups;

  /// ios easter egg on advanced settings when tapped few times
  ///
  /// In en, this message translates to:
  /// **'* To change your theme, go to Settings > PORA > Theme\n* Select a new theme from the settings menu\n* Tap on \'Theme\' in the app\'s settings to switch between light and dark modes'**
  String get settingsChangeThemeIOSEasterEgg;

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

  /// Написать письмо в поддержку
  ///
  /// In en, this message translates to:
  /// **'Написать письмо в поддержку'**
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
  /// **'You buy often'**
  String get predictionsSectionOften;

  /// FAB label
  ///
  /// In en, this message translates to:
  /// **'Ask PORA'**
  String get predictionsAskPora;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'items per week'**
  String get kpiWeek;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'recipes this month'**
  String get kpiRecipes;

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'days until restock'**
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

  /// model badge
  ///
  /// In en, this message translates to:
  /// **'Powered by OpenRouter · ling-3.0-flash'**
  String get aiModelBadge;

  /// see all link
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

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

  /// champion card kicker
  ///
  /// In en, this message translates to:
  /// **'CHAMPION OF THE MONTH'**
  String get insightsChampionKicker;

  /// champion card subtitle
  ///
  /// In en, this message translates to:
  /// **'bought {count} times this month'**
  String insightsChampionSubtitle(int count);

  /// streak headline
  ///
  /// In en, this message translates to:
  /// **'{days} days in a row'**
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

  /// kpi label
  ///
  /// In en, this message translates to:
  /// **'logins this week'**
  String get insightsStatsLoginsWeek;

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

  /// dup pill when user unchecks flag
  ///
  /// In en, this message translates to:
  /// **'will add anyway'**
  String get recipeDupForceMark;

  /// dedup banner
  ///
  /// In en, this message translates to:
  /// **'{n} duplicates will be skipped — uncheck to force-add'**
  String recipeDedupBannerMany(int n);

  /// snackbar when write attempted offline
  ///
  /// In en, this message translates to:
  /// **'No internet — change won\'t be saved'**
  String get offlineWriteBlocked;

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
