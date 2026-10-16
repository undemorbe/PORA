import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/recipe/data/datasource/browser_profile.dart';

void main() {
  group('BrowserProfile.forPlatform', () {
    test('iOS 26 freezes OS token at 18_6 like real Safari', () {
      final p = BrowserProfile.forPlatform(
        os: 'ios',
        osVersion: 'Version 26.1 (Build 23B85)',
        languageCode: 'ru',
        deviceLocale: 'ru_RU',
      );
      expect(
        p.userAgent,
        'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 '
        'Mobile/15E148 Safari/604.1',
      );
      expect(p.isMobile, isTrue);
      expect(p.acceptLanguage, 'ru-RU,ru;q=0.9,en;q=0.8');
    });

    test('iOS 18.5 keeps real OS version', () {
      final p = BrowserProfile.forPlatform(
        os: 'ios',
        osVersion: 'Version 18.5 (Build 22F76)',
        languageCode: 'en',
      );
      expect(p.userAgent, contains('CPU iPhone OS 18_5 like Mac OS X'));
      expect(p.userAgent, contains('Version/18.5'));
      expect(p.acceptLanguage, 'en');
    });

    test('macOS 15 → Safari 18, macOS 26 → Safari 26', () {
      final sequoia = BrowserProfile.forPlatform(
        os: 'macos',
        osVersion: 'Version 15.6 (Build 24G84)',
        languageCode: 'en',
        deviceLocale: 'en_US',
      );
      expect(sequoia.userAgent, contains('Intel Mac OS X 10_15_7'));
      expect(sequoia.userAgent, contains('Version/18.6 Safari/605.1.15'));
      expect(sequoia.acceptLanguage, 'en-US,en;q=0.9');

      final tahoe = BrowserProfile.forPlatform(
        os: 'macos',
        osVersion: 'Version 26.0 (Build 25A354)',
        languageCode: 'ru',
      );
      expect(tahoe.userAgent, contains('Version/26.0 Safari'));
      expect(tahoe.isMobile, isFalse);
    });

    test('android uses reduced Chrome UA; alternate flips form factor', () {
      final p = BrowserProfile.forPlatform(
        os: 'android',
        osVersion: '5.10.157-android13',
        languageCode: 'zh',
        deviceLocale: 'en_US',
      );
      expect(p.userAgent, contains('Linux; Android 10; K'));
      expect(p.userAgent, contains('Mobile Safari/537.36'));
      expect(p.acceptLanguage, 'zh,en;q=0.8');
      expect(p.alternate.isMobile, isFalse);
      expect(p.alternate.acceptLanguage, p.acceptLanguage);
    });

    test('document headers never advertise brotli', () {
      final h = BrowserProfile.forPlatform(
        os: 'ios',
        osVersion: '26.0',
        languageCode: 'ru',
      ).documentHeaders(cookie: 'a=1');
      expect(h['Accept-Encoding'], 'gzip, deflate');
      expect(h['Cookie'], 'a=1');
      expect(h.containsKey('Referer'), isFalse);
    });
  });

  group('RecipeCookieJar', () {
    test('stores site cookies, shares with subdomains, honours max-age=0', () {
      final jar = RecipeCookieJar();
      final site = Uri.parse('https://www.example.com/a');
      jar.store(
        site,
        'sid=abc; Path=/; Expires=Wed, 21 Oct 2026 07:28:00 GMT, '
        'consent=yes; Path=/',
      );
      expect(jar.headerFor(site), 'sid=abc; consent=yes');
      expect(
        jar.headerFor(Uri.parse('https://m.example.com/')),
        'sid=abc; consent=yes',
      );
      expect(jar.headerFor(Uri.parse('https://other.com/')), isNull);

      jar.store(site, 'sid=gone; Max-Age=0');
      expect(jar.headerFor(site), 'consent=yes');
    });
  });
}
