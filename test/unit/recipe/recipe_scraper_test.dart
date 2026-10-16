import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_completion.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/features/recipe/data/datasource/ai_recipe_parser.dart';
import 'package:pora/core/features/recipe/data/datasource/browser_profile.dart';
import 'package:pora/core/features/recipe/data/datasource/recipe_scraper.dart';
import 'package:pora/core/features/recipe/data/datasource/recipe_stripper_client.dart';
import 'package:pora/core/features/recipe/domain/recipe_import_failure.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

BrowserProfile _iphone(String lang) => BrowserProfile.forPlatform(
  os: 'ios',
  osVersion: 'Version 26.0.1 (Build 23A355)',
  languageCode: lang,
  deviceLocale: 'ru_RU',
);

http.Response _html(String body, {int status = 200}) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: {'content-type': 'text/html; charset=utf-8'},
);

class _FakeAi implements AiRepository {
  _FakeAi(this.reply);
  final String reply;
  int calls = 0;

  @override
  Future<Either<Failure, AiCompletionEntity>> chat({
    required List<AiMessage> messages,
    int maxTokens = 0,
    double temperature = 0,
  }) async {
    calls++;
    return Right(AiCompletionEntity(content: reply));
  }
}

const _jsonLdPage = '''
<html><head>
<meta property="og:image" content="https://img/og.jpg">
<script type="application/ld+json">
{"@context":"https://schema.org","@graph":[
  {"@type":"WebPage","name":"page"},
  {"@type":["schema:Recipe"],"name":"Борщ &amp; пампушки | Сайт",
   "recipeYield":["4","4 порции"],
   "image":{"@type":"ImageObject","url":"https://img/borsch.jpg"},
   "recipeIngredient":["Свёкла - 2 шт.","Говядина — 500 г","Соль - по вкусу","<b>Капуста</b> 300 г"]}
]}
</script></head><body></body></html>
''';

void main() {
  group('HttpRecipeScraper', () {
    test(
      'JSON-LD: entities, schema: prefix, yield list, localized units',
      () async {
        final client = MockClient((req) async => _html(_jsonLdPage));
        final scraper = HttpRecipeScraper(client: client, profile: _iphone);

        final r = await scraper.scrape('https://example.ru/borsch');

        expect(r.title, 'Борщ & пампушки');
        expect(r.servings, '4 порции');
        expect(r.imageUrl, 'https://img/borsch.jpg');
        expect(r.extractor, 'json_ld');
        expect(r.ingredients.map((i) => i.name), [
          'Свёкла',
          'Говядина',
          'Соль',
          'Капуста',
        ]);
        expect(r.ingredients[0].unit, 'шт');
        expect(r.ingredients[1].unit, 'г');
        expect(r.ingredients[2].note, 'по вкусу');
        expect(r.foodEmoji, '🍲');
      },
    );

    test('sends device-based Safari UA and no brotli', () async {
      late http.BaseRequest seen;
      final client = MockClient((req) async {
        seen = req;
        return _html(_jsonLdPage);
      });
      await HttpRecipeScraper(
        client: client,
        profile: _iphone,
      ).scrape('example.ru/borsch');

      expect(seen.headers['User-Agent'], contains('iPhone OS 18_6'));
      expect(seen.headers['User-Agent'], contains('Version/26.0'));
      expect(seen.headers['Accept-Encoding'], isNot(contains('br')));
      expect(seen.headers['Accept-Language'], startsWith('ru-RU'));
    });

    test('retries 403 with alternate profile and echoes Set-Cookie', () async {
      final requests = <http.BaseRequest>[];
      final client = MockClient((req) async {
        requests.add(req);
        if (requests.length == 1) {
          return http.Response(
            'blocked',
            403,
            headers: {'set-cookie': 'consent=yes; Path=/; Max-Age=3600'},
          );
        }
        return _html(_jsonLdPage);
      });
      final r = await HttpRecipeScraper(
        client: client,
        profile: _iphone,
      ).scrape('https://www.example.ru/borsch');

      expect(r.ingredients, hasLength(4));
      expect(requests, hasLength(2));
      expect(requests[1].headers['User-Agent'], contains('Macintosh'));
      expect(requests[1].headers['Cookie'], 'consent=yes');
    });

    test('cp1251 page decodes Ё/ё correctly', () {
      final bytes = <int>[0xA8, 0xEB, 0xEA, 0xE0, 0x20, 0xB8, 0xE6];
      final body = HttpRecipeScraper.decodeBody(
        http.Response.bytes(
          bytes,
          200,
          headers: {'content-type': 'text/html; charset=windows-1251'},
        ),
      );
      expect(body, 'Ёлка ёж');
    });

    test('heading "Ингредиенты" + list on a plain blog page', () async {
      const page = '''
<html><head><title>Блины на молоке</title></head><body><article>
<p>Длинная история про бабушку.</p>
<h2>Ингредиенты:</h2>
<ul><li>Молоко — 500 мл</li><li>Яйца — 2 шт.</li><li>Мука — 1 стакан</li>
<li>Соль</li></ul>
<h2>Приготовление</h2><p>Смешайте всё.</p>
</article></body></html>''';
      final client = MockClient((req) async {
        if (req.url.host == 'recipestripper.com') {
          return http.Response('{"success":false}', 200);
        }
        return _html(page);
      });
      final r = await HttpRecipeScraper(
        client: client,
        profile: _iphone,
      ).scrape('https://blog.example/bliny');

      expect(r.extractor, 'heading');
      expect(r.title, 'Блины на молоке');
      expect(r.ingredients.map((i) => i.name), [
        'Молоко',
        'Яйца',
        'Мука',
        'Соль',
      ]);
      expect(r.ingredients[2].unit, 'стакан');
      expect(r.foodEmoji, '🥞');
    });

    test('falls back to RecipeStripper API when page has no recipe', () async {
      final requests = <http.Request>[];
      final client = MockClient((req) async {
        requests.add(req);
        if (req.url.host == 'recipestripper.com') {
          expect(req.method, 'POST');
          expect(req.url.path, '/api/translate');
          expect(jsonDecode(req.body), {'url': 'https://spa.example/r/1'});
          return http.Response(
            jsonEncode({
              'success': true,
              'recipe': {
                'title': 'Chicken Chasseur',
                'servingsText': '4',
                'ingredients': [
                  {
                    'raw': '4 chicken thighs ((Note 1))',
                    'quantity': 4,
                    'item': 'chicken thighs ((Note 1))',
                  },
                  {
                    'raw': '3/4 tsp salt',
                    'quantity': 0.75,
                    'unit': 'tsp',
                    'item': 'salt',
                  },
                ],
              },
            }),
            200,
          );
        }
        return _html('<html><body><div id="root"></div></body></html>');
      });

      final r = await HttpRecipeScraper(
        client: client,
        profile: _iphone,
      ).scrape('https://spa.example/r/1', languageCode: 'en');

      expect(r.extractor, 'recipestripper');
      expect(r.title, 'Chicken Chasseur');
      expect(r.ingredients.map((i) => i.name), ['Chicken thighs', 'Salt']);
      expect(r.ingredients[1].quantity, '3/4');
      expect(r.ingredients[1].unit, 'tsp');
    });

    test('caches result per url+language', () async {
      var calls = 0;
      final client = MockClient((req) async {
        calls++;
        return _html(_jsonLdPage);
      });
      final scraper = HttpRecipeScraper(client: client, profile: _iphone);
      await scraper.scrape('https://example.ru/borsch');
      await scraper.scrape('https://example.ru/borsch');
      expect(calls, 1);
      await scraper.scrape('https://example.ru/borsch', languageCode: 'en');
      expect(calls, 2);
    });

    test('extracts link from shared text', () async {
      late Uri seen;
      final client = MockClient((req) async {
        seen = req.url;
        return _html(_jsonLdPage);
      });
      await HttpRecipeScraper(
        client: client,
        profile: _iphone,
      ).scrape('Смотри рецепт: https://example.ru/borsch?x=1 — вкусно!');
      expect(seen.toString(), 'https://example.ru/borsch?x=1');
    });

    test('invalid url → typed exception', () {
      expect(
        () => HttpRecipeScraper(
          client: MockClient((_) async => _html('')),
        ).scrape('not a url'),
        throwsA(
          isA<RecipeScrapeException>().having(
            (e) => e.kind,
            'kind',
            RecipeScrapeErrorKind.invalidUrl,
          ),
        ),
      );
    });

    test('AI may not drop >40% of a trusted ingredient list', () async {
      const englishPage = '''
<script type="application/ld+json">
{"@type":"Recipe","name":"Pancakes","recipeIngredient":[
"2 cups flour, spooned and leveled","2 eggs","1 cup milk","1 tbsp sugar","1 tsp salt"]}
</script>''';
      final ai = _FakeAi(
        '{"title":"Блины","foodEmoji":"🥞","ingredients":'
        '[{"name":"мука","quantity":"2","unit":"cup"}]}',
      );
      final r = await HttpRecipeScraper(
        client: MockClient((_) async => _html(englishPage)),
        profile: _iphone,
        aiParser: AiRecipeParser(ai: ai),
      ).scrape('https://example.com/pancakes');

      expect(ai.calls, 1, reason: 'english names for ru user → AI runs');
      expect(r.ingredients, hasLength(5));
      expect(r.extractor, 'json_ld');
    });

    test('clean data in user language skips AI', () async {
      final ai = _FakeAi('{}');
      await HttpRecipeScraper(
        client: MockClient((_) async => _html(_jsonLdPage)),
        profile: _iphone,
        aiParser: AiRecipeParser(ai: ai),
      ).scrape('https://example.ru/borsch');
      expect(ai.calls, 0);
    });
  });

  group('RecipeStripperClient.parseResponse', () {
    test('russian items keep amounts inside raw', () {
      final r = RecipeStripperClient.parseResponse({
        'success': true,
        'recipe': {
          'title': 'Мармелад из айвы',
          'ingredients': [
            {'raw': 'Сахар - 400 г', 'item': 'Сахар - 400 г'},
            {
              'raw': 'Айва - 500 г (400 г очищенной)',
              'item': 'Айва - 500 г',
              'preparation': '400 г очищенной',
            },
          ],
        },
      }, 'https://russianfood.com/x');
      expect(r, isNotNull);
      expect(r!.ingredients[0].name, 'Сахар');
      expect(r.ingredients[0].quantity, '400');
      expect(r.ingredients[1].note, '400 г очищенной');
    });

    test('failure / garbage → null', () {
      expect(
        RecipeStripperClient.parseResponse({
          'success': false,
          'errorType': 'not_a_recipe_site',
        }, 'u'),
        isNull,
      );
      expect(RecipeStripperClient.parseResponse('oops', 'u'), isNull);
    });
  });
}
