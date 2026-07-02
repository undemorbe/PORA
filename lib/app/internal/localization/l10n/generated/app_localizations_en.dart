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
  String get language => 'English';

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
}
