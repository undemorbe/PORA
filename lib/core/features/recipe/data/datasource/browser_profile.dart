import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// HTTP-профиль «браузера» для загрузки страниц рецептов.
///
/// Строится из реальной ОС пользователя: на iPhone с iOS 26 уходит UA
/// Safari iOS 26, на Mac — Safari macOS и т.д. Сайты отдают ту же вёрстку,
/// что пользователь видит в своём браузере, и реже режут запрос как бота.
///
/// Cookie здесь не подделываются: [RecipeCookieJar] только хранит то, что
/// сайт сам выставил через `Set-Cookie`, как это делает браузер.
class BrowserProfile {
  const BrowserProfile({
    required this.userAgent,
    required this.acceptLanguage,
    required this.isMobile,
    required this.isSafari,
  });

  final String userAgent;
  final String acceptLanguage;
  final bool isMobile;
  final bool isSafari;

  /// Последний стабильный Chrome на момент релиза — Chrome UA reduction
  /// замораживает всё, кроме major-версии.
  static const String chromeMajor = '141';

  static const String _webKit = 'AppleWebKit/605.1.15 (KHTML, like Gecko)';

  /// Профиль текущего устройства.
  static BrowserProfile current(String languageCode) {
    if (kIsWeb) {
      // В вебе UA проставляет сам браузер; значение ни на что не влияет.
      return forPlatform(
        os: 'macos',
        osVersion: '15.0',
        languageCode: languageCode,
      );
    }
    return forPlatform(
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      languageCode: languageCode,
      deviceLocale: Platform.localeName,
    );
  }

  /// Чистая фабрика (тестируемая): [os] — `Platform.operatingSystem`,
  /// [osVersion] — `Platform.operatingSystemVersion` («Version 26.0.1
  /// (Build 23A355)», «Version 15.6 (Build 24G84)», kernel-строка Android).
  static BrowserProfile forPlatform({
    required String os,
    required String osVersion,
    required String languageCode,
    String? deviceLocale,
  }) {
    final v = _version(osVersion);
    final lang = _acceptLanguage(languageCode, deviceLocale);
    switch (os) {
      case 'ios':
        return BrowserProfile(
          userAgent: iosSafari(v.major ?? 18, v.minor ?? 0, v.patch ?? 0),
          acceptLanguage: lang,
          isMobile: true,
          isSafari: true,
        );
      case 'macos':
        return BrowserProfile(
          userAgent: macSafari(v.major ?? 15, v.minor ?? 0),
          acceptLanguage: lang,
          isMobile: false,
          isSafari: true,
        );
      case 'android':
        return BrowserProfile(
          userAgent:
              'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/$chromeMajor.0.0.0 '
              'Mobile Safari/537.36',
          acceptLanguage: lang,
          isMobile: true,
          isSafari: false,
        );
      case 'windows':
        return BrowserProfile(
          userAgent:
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/$chromeMajor.0.0.0 Safari/537.36',
          acceptLanguage: lang,
          isMobile: false,
          isSafari: false,
        );
      default:
        return BrowserProfile(
          userAgent:
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/$chromeMajor.0.0.0 Safari/537.36',
          acceptLanguage: lang,
          isMobile: false,
          isSafari: false,
        );
    }
  }

  /// Safari на iPhone. С iOS 26 Apple заморозила версию ОС в UA на
  /// `18_6`, а реальную версию показывает только `Version/`.
  static String iosSafari(int major, int minor, int patch) {
    final osToken = major >= 26
        ? '18_6'
        : [major, minor, if (patch > 0) patch].join('_');
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS $osToken like Mac OS X) '
        '$_webKit Version/$major.$minor Mobile/15E148 Safari/604.1';
  }

  /// Safari на Mac. ОС в UA заморожена на 10_15_7; версия Safari
  /// совпадает с macOS начиная с 26, до этого — macOS + 3 (15 → 18).
  static String macSafari(int major, int minor) {
    final safari = major >= 26 ? major : (major >= 11 ? major + 3 : 17);
    return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) $_webKit '
        'Version/$safari.$minor Safari/605.1.15';
  }

  /// Запасной профиль противоположного форм-фактора — для повтора, если
  /// сайт отказал (403/429/503) текущему.
  BrowserProfile get alternate => isMobile
      ? BrowserProfile(
          userAgent: macSafari(26, 0),
          acceptLanguage: acceptLanguage,
          isMobile: false,
          isSafari: true,
        )
      : BrowserProfile(
          userAgent: iosSafari(26, 0, 0),
          acceptLanguage: acceptLanguage,
          isMobile: true,
          isSafari: true,
        );

  /// Заголовки навигации на HTML-страницу.
  Map<String, String> documentHeaders({String? cookie, String? referer}) => {
    'User-Agent': userAgent,
    'Accept': isSafari
        ? 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        : 'text/html,application/xhtml+xml,application/xml;q=0.9,'
              'image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': acceptLanguage,
    // dart:io распаковывает только gzip/deflate: `br` дал бы мусор в теле.
    'Accept-Encoding': 'gzip, deflate',
    'Upgrade-Insecure-Requests': '1',
    if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
    'Referer': ?referer,
  };

  /// Заголовки JSON-запроса к API (fetch из страницы [origin]).
  Map<String, String> apiHeaders({required String origin}) => {
    'User-Agent': userAgent,
    'Accept': 'application/json, */*;q=0.8',
    'Accept-Language': acceptLanguage,
    'Accept-Encoding': 'gzip, deflate',
    'Content-Type': 'application/json',
    'Origin': origin,
    'Referer': '$origin/',
  };

  static ({int? major, int? minor, int? patch}) _version(String raw) {
    final m = RegExp(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?').firstMatch(raw);
    return (
      major: int.tryParse(m?[1] ?? ''),
      minor: int.tryParse(m?[2] ?? ''),
      patch: int.tryParse(m?[3] ?? ''),
    );
  }

  /// `ru` + `ru_RU` → `ru-RU,ru;q=0.9,en;q=0.8`.
  static String _acceptLanguage(String languageCode, String? deviceLocale) {
    final lang = languageCode.toLowerCase().split(RegExp('[-_]')).first;
    final parts = (deviceLocale ?? '').split(RegExp('[-_.]'));
    final region =
        parts.length > 1 &&
            parts.first.toLowerCase() == lang &&
            RegExp(r'^[A-Za-z]{2}$').hasMatch(parts[1])
        ? parts[1].toUpperCase()
        : null;
    return [
      if (region != null) '$lang-$region',
      region == null ? lang : '$lang;q=0.9',
      if (lang != 'en') 'en;q=0.8',
    ].join(',');
  }
}

/// In-memory cookie jar по хостам — только cookie, которые сайт сам
/// выставил (consent, anti-bot challenge). Живёт до перезапуска приложения.
class RecipeCookieJar {
  static const _maxPerHost = 30;
  final Map<String, Map<String, String>> _byHost = {};

  static String _hostKey(String host) =>
      host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');

  /// Значение для заголовка `Cookie` или `null`.
  String? headerFor(Uri uri) {
    final key = _hostKey(uri.host);
    final cookies = <String, String>{};
    _byHost.forEach((host, values) {
      if (key == host || key.endsWith('.$host')) cookies.addAll(values);
    });
    if (cookies.isEmpty) return null;
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// Принимает склеенный пакетом `http` заголовок `set-cookie`
  /// (несколько cookie через запятую; запятые бывают и в `Expires`).
  void store(Uri uri, String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) return;
    final jar = _byHost.putIfAbsent(_hostKey(uri.host), () => {});
    for (final cookie in setCookie.split(RegExp(r',(?=\s*[^;,=\s]+=)'))) {
      final pair = cookie.split(';').first.trim();
      final eq = pair.indexOf('=');
      if (eq <= 0) continue;
      final name = pair.substring(0, eq).trim();
      final value = pair.substring(eq + 1).trim();
      final expired = RegExp(
        r';\s*max-age=0\b',
        caseSensitive: false,
      ).hasMatch(cookie);
      if (expired || value.isEmpty) {
        jar.remove(name);
      } else if (jar.length < _maxPerHost || jar.containsKey(name)) {
        jar[name] = value;
      }
    }
  }

  void clear() => _byHost.clear();
}
