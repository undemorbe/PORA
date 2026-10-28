import 'dart:async';
import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:pora/core/features/recipe/data/datasource/browser_profile.dart';
import 'package:pora/core/features/recipe/data/datasource/ingredient_line_parser.dart';
import 'package:pora/core/features/recipe/data/datasource/youtube_recipe_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/recipe_import_failure.dart';
import 'package:pora/core/features/recipe/domain/recipe_units.dart';
import 'package:pora/core/features/recipe/data/datasource/ai_recipe_parser.dart';
import 'package:pora/core/features/recipe/data/datasource/recipe_stripper_client.dart';
// Пакет экспортирует только `scrapeRecipe` (свой fetch без UA/таймаута),
// нам нужен разбор уже загруженного JSON-LD.
// ignore: implementation_imports
import 'package:recipe_scraper/src/recipe_scraper_base.dart'
    as rs_pkg
    show decodeRecipeData;

abstract class RecipeScraper {
  Future<RecipeEntity> scrape(String url, {String languageCode = 'ru'});
}

/// Кандидат-рецепт: `trusted` — из структурированных данных (JSON-LD,
/// микроразметка, плагины WordPress, внешний экстрактор), им можно верить
/// без AI-проверки.
typedef _Candidate = ({RecipeEntity recipe, bool trusted});

/// Импорт рецепта по ссылке. Порядок источников:
///
/// 1. Страница грузится с заголовками браузера пользователя
///    (`BrowserProfile`); при 403/429/503 — повтор альтернативным профилем.
/// 2. Локально: JSON-LD → пакет `recipe_scraper` → плагины (WPRM, Tasty…)
///    → microdata → адаптеры сайтов → заголовок «Ингредиенты» → эвристики.
/// 3. Если надёжного результата нет или страница не загрузилась —
///    внешние экстракторы (RecipeStripper, JustTheRecipe) параллельно.
/// 4. AI нормализует/переводит ингредиенты, но не может «потерять» больше
///    40% позиций надёжного источника; для чистых данных на языке
///    пользователя AI пропускается (быстрее и без галлюцинаций).
/// 5. AI-разбор текста страницы — последний шанс для неструктурированных.
///
/// Результат кэшируется в памяти (url + язык) на 30 минут.
class HttpRecipeScraper implements RecipeScraper {
  HttpRecipeScraper({
    http.Client? client,
    this.aiParser,
    YouTubeRecipeParser? youtubeParser,
    RecipeStripperClient? recipeStripper,
    BrowserProfile Function(String languageCode)? profile,
    DateTime Function()? clock,
    this.pageTimeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _youtubeParser =
           youtubeParser ??
           YouTubeRecipeParser(client: client, aiParser: aiParser),
       _stripper = recipeStripper ?? RecipeStripperClient(client: client),
       _profile = profile ?? BrowserProfile.current,
       _clock = clock ?? DateTime.now;

  final http.Client _client;
  final AiRecipeParser? aiParser;
  final YouTubeRecipeParser _youtubeParser;
  final RecipeStripperClient _stripper;
  final BrowserProfile Function(String languageCode) _profile;
  final DateTime Function() _clock;
  final Duration pageTimeout;
  final RecipeCookieJar _cookies = RecipeCookieJar();

  static const _cacheTtl = Duration(minutes: 30);
  static const _cacheSize = 20;
  final Map<String, ({DateTime at, RecipeEntity recipe})> _cache = {};

  static const _retryStatuses = {403, 406, 429, 503};

  @override
  Future<RecipeEntity> scrape(String url, {String languageCode = 'ru'}) async {
    final uri = _normalizeUrl(url);
    final key = '$languageCode|$uri';

    final hit = _cache.remove(key);
    if (hit != null && _clock().difference(hit.at) < _cacheTtl) {
      _cache[key] = hit; // LRU: в конец.
      return hit.recipe;
    }

    final raw = YouTubeUrl.isYouTube(uri)
        ? await _scrapeYouTube(uri, languageCode: languageCode)
        : await _scrapeHtml(uri, languageCode: languageCode);
    final recipe = _finalize(raw, languageCode);

    _cache[key] = (at: _clock(), recipe: recipe);
    while (_cache.length > _cacheSize) {
      _cache.remove(_cache.keys.first);
    }
    return recipe;
  }

  Future<RecipeEntity> _scrapeYouTube(
    Uri uri, {
    required String languageCode,
  }) async {
    final result = await _youtubeParser.parse(uri, languageCode: languageCode);
    if (result == null) {
      throw const RecipeScrapeException(
        'Не удалось извлечь рецепт из YouTube.',
        kind: RecipeScrapeErrorKind.youtube,
      );
    }
    return result;
  }

  Future<RecipeEntity> _scrapeHtml(
    Uri uri, {
    required String languageCode,
    bool allowIndexFallback = true,
  }) async {
    final page = await _fetchPage(uri, languageCode);
    final document = page.document;

    if (document == null) {
      // Сайт закрыт для прямого запроса (anti-bot, гео) — серверный
      // экстрактор часто всё равно достаёт рецепт.
      final external = await _externalFallback(uri, languageCode);
      if (external != null) {
        return _normalizeWithAi(
          document: null,
          candidate: external,
          sourceUrl: uri.toString(),
          languageCode: languageCode,
        );
      }
      final error = page.error;
      if (error != null) throw error;
      throw RecipeScrapeException(
        'HTTP ${page.status} for $uri',
        kind: RecipeScrapeErrorKind.http,
      );
    }

    final finalUrl = page.finalUrl;
    var candidate = _extractLocal(document, finalUrl);

    if (!candidate.trusted) {
      final external = await _externalFallback(
        Uri.parse(finalUrl),
        languageCode,
      );
      if (external != null &&
          external.recipe.ingredients.length >=
              candidate.recipe.ingredients.length) {
        candidate = (
          recipe: _withPageMetadata(external.recipe, candidate.recipe),
          trusted: true,
        );
      }
    }

    if (candidate.recipe.ingredients.isEmpty && allowIndexFallback) {
      final recipeLink = _findRecipeLink(document, Uri.parse(finalUrl));
      if (recipeLink != null) {
        try {
          return await _scrapeHtml(
            recipeLink,
            languageCode: languageCode,
            allowIndexFallback: false,
          );
        } on RecipeScrapeException {
          // Ссылка устарела — пробуем AI по исходной странице.
        }
      }
    }

    if (candidate.recipe.ingredients.isNotEmpty) {
      return _normalizeWithAi(
        document: document,
        candidate: candidate,
        sourceUrl: finalUrl,
        languageCode: languageCode,
      );
    }

    // AI-разбор полностью неструктурированной страницы.
    if (aiParser != null) {
      final input = _buildAiInput(document, candidate.recipe, maxText: 10000);
      if (input.readableText.isNotEmpty) {
        try {
          final aiRecipe = await aiParser!.parse(
            pageText: input.toText(),
            sourceUrl: finalUrl,
            languageCode: languageCode,
          );
          if (aiRecipe != null && aiRecipe.ingredients.isNotEmpty) {
            return _mergeRecipeMetadata(
              aiRecipe,
              candidate.recipe,
              finalUrl,
            ).copyWith(extractor: 'ai');
          }
        } catch (_) {
          // Сбой провайдера → ниже понятная ошибка.
        }
      }
    }

    throw const RecipeScrapeException(
      'Не удалось найти ингредиенты на странице.',
      kind: RecipeScrapeErrorKind.noIngredients,
    );
  }

  //! --- Загрузка ---

  Future<
    ({dom.Document? document, String finalUrl, int? status, Object? error})
  >
  _fetchPage(Uri uri, String languageCode) async {
    final primary = _profile(languageCode);
    int? status;
    Object? error;

    for (final profile in [primary, primary.alternate]) {
      try {
        final response = await _client
            .get(
              uri,
              headers: profile.documentHeaders(cookie: _cookies.headerFor(uri)),
            )
            .timeout(pageTimeout);
        final responseUri = response.request?.url ?? uri;
        _cookies.store(responseUri, response.headers['set-cookie']);
        status = response.statusCode;
        if (status >= 200 && status < 400) {
          return (
            document: html_parser.parse(decodeBody(response)),
            finalUrl: responseUri.toString(),
            status: status,
            error: null,
          );
        }
        // Повтор имеет смысл только для отказов «не похож на браузер».
        if (!_retryStatuses.contains(status)) break;
        error = null;
      } catch (e) {
        error = e;
        break;
      }
    }
    return (
      document: null,
      finalUrl: uri.toString(),
      status: status,
      error: error,
    );
  }

  /// Внешние экстракторы параллельно; лучший по числу ингредиентов.
  Future<_Candidate?> _externalFallback(Uri uri, String languageCode) async {
    final results = await Future.wait([
      _stripper.fetch(uri, profile: _profile(languageCode)),
      _fetchJustTheRecipe(uri, languageCode),
    ]);
    RecipeEntity? best;
    for (final r in results) {
      if (r == null || r.ingredients.isEmpty) continue;
      if (best == null || r.ingredients.length > best.ingredients.length) {
        best = r;
      }
    }
    return best == null ? null : (recipe: best, trusted: true);
  }

  Future<RecipeEntity?> _fetchJustTheRecipe(
    Uri sourceUri,
    String languageCode,
  ) async {
    final host = sourceUri.host.toLowerCase();
    const supported = [
      'russianfood.com',
      'food.ru',
      'povar.ru',
      'iamcook.ru',
      'recipetineats.com',
      'allrecipes.com',
    ];
    if (!supported.any(host.endsWith)) return null;

    final endpoint = Uri.https('www.justtherecipe.com', '/extractRecipeAtUrl', {
      'url': sourceUri.toString(),
    });
    try {
      final response = await _client
          .get(
            endpoint,
            headers: _profile(
              languageCode,
            ).apiHeaders(origin: 'https://www.justtherecipe.com'),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) return null;
      final rawIngredients = decoded['ingredients'];
      if (rawIngredients is! List) return null;

      final ingredients = <RecipeIngredient>[];
      for (final raw in rawIngredients) {
        final name = raw is Map ? _asString(raw['name']) : _asString(raw);
        if (name == null) continue;
        _addIngredient(ingredients, name, strict: false);
      }
      if (ingredients.isEmpty) return null;

      final images = decoded['imageUrls'];
      return RecipeEntity(
        title: _asString(decoded['name']) ?? '',
        imageUrl: images is List && images.isNotEmpty
            ? _asString(images.first)
            : null,
        servings: _asString(decoded['servings']),
        sourceUrl: sourceUri.toString(),
        ingredients: ingredients,
        extractor: 'justtherecipe',
      );
    } catch (_) {
      return null;
    }
  }

  //! --- Кодировки ---

  /// Тело ответа с учётом charset из заголовка или `<meta>`.
  static String decodeBody(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final bytes = response.bodyBytes;
    var charset = RegExp(
      r'charset=([^\s;]+)',
      caseSensitive: false,
    ).firstMatch(contentType)?.group(1);
    if (charset == null) {
      final probe = utf8.decode(
        bytes.take(4096).toList(),
        allowMalformed: true,
      );
      charset = RegExp(
        r'''charset\s*=\s*["']?([\w-]+)''',
        caseSensitive: false,
      ).firstMatch(probe)?.group(1);
    }
    switch (charset?.toLowerCase().replaceAll('"', '')) {
      case 'windows-1251':
      case 'cp1251':
      case 'win-1251':
        return decodeWindows1251(bytes);
      case 'iso-8859-1':
      case 'latin1':
      case 'windows-1252':
        return latin1.decode(bytes, allowInvalid: true);
      default:
        return utf8.decode(bytes, allowMalformed: true);
    }
  }

  /// Windows-1251 → String. Таблица 0x80–0xBF по спецификации (раньше в
  /// ней не хватало позиции 0x98, и `Ё`/`ё` превращались в соседние буквы).
  static String decodeWindows1251(List<int> bytes) {
    const high = <int>[
      0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021, //
      0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F,
      0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
      0xFFFD, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F,
      0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7,
      0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407,
      0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7,
      0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457,
    ];
    final codes = List<int>.filled(bytes.length, 0);
    for (var i = 0; i < bytes.length; i++) {
      final b = bytes[i];
      codes[i] = b < 0x80
          ? b
          : b >= 0xC0
          ? 0x0410 + b - 0xC0
          : high[b - 0x80];
    }
    return String.fromCharCodes(codes);
  }

  Uri _normalizeUrl(String raw) {
    // Из «шаринга» часто прилетает текст со ссылкой внутри.
    final value = raw.trim();
    if (value.isEmpty) {
      throw const RecipeScrapeException(
        'Пустой URL.',
        kind: RecipeScrapeErrorKind.invalidUrl,
      );
    }
    final embedded = RegExp(r'https?://\S+').firstMatch(value)?.group(0);
    final candidate = (embedded ?? value).replaceAll(
      RegExp(r'[).,;!?»"]+$'),
      '',
    );
    final normalized =
        candidate.startsWith('http://') || candidate.startsWith('https://')
        ? candidate
        : 'https://$candidate';
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      throw const RecipeScrapeException(
        'Некорректный URL.',
        kind: RecipeScrapeErrorKind.invalidUrl,
      );
    }
    return uri;
  }

  //! --- Локальное извлечение ---

  _Candidate _extractLocal(dom.Document document, String sourceUrl) {
    // Надёжные источники — первый с ≥2 ингредиентами выигрывает сразу.
    final trustedSources = <RecipeEntity? Function()>[
      () => _tryJsonLd(document, sourceUrl),
      () => _tryPackageJsonLd(document, sourceUrl),
      () => _fromRecipePlugins(document, sourceUrl),
      () => _fromMicrodata(document, sourceUrl),
    ];
    final weak = <RecipeEntity>[];
    for (final source in trustedSources) {
      final recipe = source();
      if (recipe == null) continue;
      if (recipe.ingredients.length >= 2) {
        return (
          recipe: _withPageMetadataFromDoc(recipe, document),
          trusted: true,
        );
      }
      weak.add(recipe);
    }

    weak.addAll([
      ?_fromSiteAdapter(document, sourceUrl),
      ?_fromIngredientHeading(document, sourceUrl),
      _fromHtmlHeuristics(document, sourceUrl),
    ]);
    final best = weak.reduce(
      (a, b) => b.ingredients.length > a.ingredients.length ? b : a,
    );
    return (recipe: _withPageMetadataFromDoc(best, document), trusted: false);
  }

  RecipeEntity _withPageMetadataFromDoc(
    RecipeEntity recipe,
    dom.Document document,
  ) {
    return recipe.copyWith(
      title: recipe.title.trim().isEmpty ? _documentTitle(document) : null,
      imageUrl: recipe.imageUrl ?? _metaContent(document, 'og:image'),
    );
  }

  RecipeEntity _withPageMetadata(RecipeEntity primary, RecipeEntity page) {
    return primary.copyWith(
      title: primary.title.trim().isEmpty ? page.title : null,
      imageUrl: primary.imageUrl ?? page.imageUrl,
      servings: primary.servings ?? page.servings,
    );
  }

  // JSON-LD ------------------------------------------------------------------

  RecipeEntity? _tryJsonLd(dom.Document document, String sourceUrl) {
    RecipeEntity? best;
    for (final script in document.querySelectorAll(
      'script[type="application/ld+json"]',
    )) {
      final decoded = _decodeJsonLd(script.text.trim());
      if (decoded == null) continue;
      for (final node in _findRecipeNodes(decoded)) {
        final ingredients = _extractIngredients(
          node['recipeIngredient'] ?? node['ingredients'],
        );
        if (ingredients.isEmpty) continue;
        if (best != null && best.ingredients.length >= ingredients.length) {
          continue;
        }
        best = RecipeEntity(
          title: _plain(_asString(node['name']) ?? ''),
          imageUrl: _extractImageUrl(node['image']),
          servings: _yield(node['recipeYield'] ?? node['yield']),
          sourceUrl: sourceUrl,
          ingredients: ingredients,
          extractor: 'json_ld',
        );
      }
    }
    return best;
  }

  /// Fallback через пакет `recipe_scraper` (схема с `"@type": "Recipe"`).
  /// Пакет бросает исключения на нестандартной разметке — изолируем.
  RecipeEntity? _tryPackageJsonLd(dom.Document document, String sourceUrl) {
    for (final script in document.querySelectorAll(
      'script[type="application/ld+json"]',
    )) {
      try {
        final decoded = _decodeJsonLd(script.text.trim());
        if (decoded == null) continue;
        final recipe = rs_pkg.decodeRecipeData(decoded, sourceUrl);
        if (recipe == null || recipe.ingredients.isEmpty) continue;
        final ingredients = <RecipeIngredient>[];
        for (final ing in recipe.ingredients) {
          final qty = ing.quantity;
          final line = [
            if (qty != 1) _formatNum(qty),
            ?ing.unit,
            ing.name,
          ].join(' ');
          _addIngredient(ingredients, line, strict: false);
        }
        if (ingredients.isEmpty) continue;
        return RecipeEntity(
          title: _plain(recipe.title),
          imageUrl: recipe.imageUrls.isEmpty ? null : recipe.imageUrls.first,
          servings: recipe.servings > 0 ? '${recipe.servings}' : null,
          sourceUrl: sourceUrl,
          ingredients: _dedupeIngredients(ingredients),
          extractor: 'recipe_scraper_pkg',
        );
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static String _formatNum(num value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  dynamic _decodeJsonLd(String raw) {
    if (raw.isEmpty) return null;
    for (final attempt in [
      raw,
      // Сырые переводы строк внутри строк JSON (частая ошибка CMS).
      raw.replaceAll(RegExp(r'[\u0000-\u001F]'), ' '),
    ]) {
      try {
        return jsonDecode(attempt);
      } catch (_) {}
      // Комментарии/мусор вокруг JSON.
      final objectStart = attempt.indexOf('{');
      final objectEnd = attempt.lastIndexOf('}');
      final arrayStart = attempt.indexOf('[');
      final arrayEnd = attempt.lastIndexOf(']');
      final useArray =
          arrayStart >= 0 &&
          arrayEnd > arrayStart &&
          (objectStart < 0 || arrayStart < objectStart);
      final start = useArray ? arrayStart : objectStart;
      final end = useArray ? arrayEnd : objectEnd;
      if (start >= 0 && end > start) {
        try {
          return jsonDecode(attempt.substring(start, end + 1));
        } catch (_) {}
      }
    }
    return null;
  }

  Iterable<Map<String, dynamic>> _findRecipeNodes(dynamic node) sync* {
    if (node is List) {
      for (final child in node) {
        yield* _findRecipeNodes(child);
      }
    } else if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      if (_isRecipeType(map['@type'])) {
        yield map;
        return;
      }
      for (final value in map.values) {
        yield* _findRecipeNodes(value);
      }
    }
  }

  /// `Recipe`, `schema:Recipe`, `http://schema.org/Recipe`, `["Recipe", …]`.
  bool _isRecipeType(dynamic type) {
    if (type is String) {
      return type.split(RegExp(r'[/:#]')).last.trim().toLowerCase() == 'recipe';
    }
    if (type is List) return type.any(_isRecipeType);
    return false;
  }

  List<RecipeIngredient> _extractIngredients(dynamic raw) {
    final values = raw is List
        ? raw
        : raw is String
        ? [raw]
        : const [];
    final result = <RecipeIngredient>[];
    for (final item in values) {
      final text = item is Map
          ? _asString(item['name']) ??
                _asString(item['text']) ??
                _asString(item['value'])
          : _asString(item);
      if (text == null) continue;
      _addIngredient(result, _plain(text), strict: false);
    }
    return _dedupeIngredients(result);
  }

  String? _extractImageUrl(dynamic raw) {
    if (raw is String) return raw.trim().isEmpty ? null : raw.trim();
    if (raw is List && raw.isNotEmpty) return _extractImageUrl(raw.first);
    if (raw is Map) {
      return _asString(raw['url']) ?? _asString(raw['contentUrl']);
    }
    return null;
  }

  /// `recipeYield`: `"4"`, `4`, `["4", "4 servings"]`, `{"value": 4}`.
  String? _yield(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return _formatNum(raw);
    if (raw is List) {
      if (raw.isEmpty) return null;
      final described = raw
          .map(_asString)
          .whereType<String>()
          .where((s) => RegExp(r'\D').hasMatch(s));
      return described.isNotEmpty ? described.first : _yield(raw.first);
    }
    if (raw is Map) return _yield(raw['value'] ?? raw['text']);
    final s = _asString(raw);
    return s == null ? null : _plain(s);
  }

  // Плагины WordPress и популярные конструкторы -------------------------------

  static const _pluginSelectors = [
    '.tasty-recipes-ingredients li',
    '.tasty-recipe-ingredients li',
    '.mv-create-ingredients li',
    '.wpzoom-rcb-ingredient',
    '.zrdn-ingredients li',
    '.ERSIngredients li',
    '.cookbook-ingredients li',
    '.recipe-ingredients__item',
    '.ingredients-item-name',
    '.mntl-structured-ingredients__list-item',
  ];

  RecipeEntity? _fromRecipePlugins(dom.Document document, String sourceUrl) {
    final ingredients = <RecipeIngredient>[];

    // WP Recipe Maker: количество/единица/название в отдельных span.
    for (final el in document.querySelectorAll('.wprm-recipe-ingredient')) {
      String part(String cls) => IngredientLineParser.clean(
        el.querySelector('.wprm-recipe-ingredient-$cls')?.text ?? '',
      );
      final name = part('name');
      if (name.isEmpty) {
        _addIngredient(ingredients, el.text, strict: false);
        continue;
      }
      final parsed = IngredientLineParser.parse(
        [
          part('amount'),
          part('unit'),
          name,
        ].where((s) => s.isNotEmpty).join(' '),
      );
      final notes = part('notes').replaceAll(RegExp(r'^\(|\)$'), '').trim();
      ingredients.add(
        notes.isEmpty
            ? parsed
            : parsed.copyWith(note: [?parsed.note, notes].join('; ')),
      );
    }

    if (ingredients.length < 2) {
      for (final selector in _pluginSelectors) {
        for (final el in document.querySelectorAll(selector)) {
          _addIngredient(ingredients, el.text, strict: false);
        }
        if (ingredients.length >= 2) break;
      }
    }
    if (ingredients.length < 2) return null;

    final title =
        document.querySelector('.wprm-recipe-name')?.text ??
        document.querySelector('.tasty-recipes-title')?.text ??
        document.querySelector('.mv-create-title')?.text;
    return RecipeEntity(
      title: IngredientLineParser.clean(title ?? ''),
      imageUrl: _metaContent(document, 'og:image'),
      servings: IngredientLineParser.clean(
        document.querySelector('.wprm-recipe-servings')?.text ?? '',
      ).nullIfEmpty,
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
      extractor: 'plugin',
    );
  }

  RecipeEntity? _fromMicrodata(dom.Document document, String sourceUrl) {
    final recipeRoot = document.querySelector(
      '[itemscope][itemtype*="Recipe"]',
    );
    final ingredients = <RecipeIngredient>[];
    for (final element in (recipeRoot ?? document).querySelectorAll(
      '[itemprop="recipeIngredient"], [itemprop="ingredients"]',
    )) {
      _addIngredient(
        ingredients,
        element.attributes['content'] ?? element.text,
        strict: false,
      );
    }
    if (ingredients.isEmpty) return null;

    final image = recipeRoot?.querySelector('[itemprop="image"]');
    final servings = IngredientLineParser.clean(
      recipeRoot?.querySelector('[itemprop="recipeYield"]')?.text ?? '',
    );
    return RecipeEntity(
      title: IngredientLineParser.clean(
        recipeRoot?.querySelector('[itemprop="name"]')?.text ?? '',
      ),
      imageUrl: image?.attributes['content'] ?? image?.attributes['src'],
      servings: servings.nullIfEmpty,
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
      extractor: 'microdata',
    );
  }

  // Адаптеры сайтов ----------------------------------------------------------

  RecipeEntity? _fromSiteAdapter(dom.Document document, String sourceUrl) {
    final host = Uri.tryParse(sourceUrl)?.host.toLowerCase() ?? '';
    final selectors = <String>[];

    if (host.endsWith('russianfood.com')) {
      selectors.addAll(['.ingr tr', '.ingredients-list li', '.recipe_list li']);
    } else if (host.endsWith('food.ru')) {
      selectors.addAll([
        '[data-ingredient]',
        '[class*="ingredient"] li',
        '[class*="Ingredient"]',
      ]);
    } else if (host.endsWith('povar.ru')) {
      selectors.addAll([
        '.ingredients-list li',
        '.ingredients li',
        '.ingredient',
      ]);
    } else if (host.endsWith('iamcook.ru')) {
      selectors.addAll(['.ingredients-list li', '.ingredients li']);
    } else if (host.endsWith('eda.ru')) {
      selectors.addAll([
        '[itemprop="recipeIngredient"]',
        '[class*="ingredients-list"] li',
        '[class*="IngredientsList"] [class*="Item"]',
      ]);
    } else {
      return null;
    }

    final ingredients = <RecipeIngredient>[];
    for (final selector in selectors) {
      for (final element in document.querySelectorAll(selector)) {
        _addIngredient(
          ingredients,
          element.attributes['data-ingredient'] ?? element.text,
          strict: false,
        );
      }
      if (ingredients.length >= 2) break;
    }

    if (ingredients.length < 2 && host.endsWith('russianfood.com')) {
      ingredients.addAll(
        _linesBetween(
          document,
          start: RegExp(r'^Продукты', caseSensitive: false),
          end: RegExp(r'^Пошаговый\s+(?:фото\s+)?рецепт', caseSensitive: false),
        ),
      );
    }
    if (ingredients.isEmpty) return null;
    return RecipeEntity(
      title: _documentTitle(document),
      imageUrl: _metaContent(document, 'og:image'),
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
      extractor: 'site',
    );
  }

  /// Строки блочного текста между заголовками [start] и [end] (строго:
  /// только строки с количеством / «по вкусу»).
  List<RecipeIngredient> _linesBetween(
    dom.Document document, {
    required RegExp start,
    required RegExp end,
  }) {
    final lines = blockText(document.body).split('\n');
    final result = <RecipeIngredient>[];
    var inside = false;
    for (final line in lines) {
      if (!inside) {
        inside = start.hasMatch(line);
        continue;
      }
      if (end.hasMatch(line)) break;
      _addIngredient(result, line);
    }
    return result;
  }

  // Заголовок «Ингредиенты» + следующий список ------------------------------

  static final _ingredientsHeading = RegExp(
    r'^(?:ингредиенты|продукты|состав|нам понадобится|вам понадобится|'
    r'понадобится|что нужно|ingredients?|you(?:\x27|’)?ll need|what you need)'
    r'\s*(?:\([^)]*\))?\s*:?\s*$',
    caseSensitive: false,
    unicode: true,
  );

  static const _headingTags = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6'};

  RecipeEntity? _fromIngredientHeading(dom.Document document, String url) {
    final body = document.body;
    if (body == null) return null;

    for (final heading in body.querySelectorAll(
      'h2, h3, h4, h5, strong, b, p',
    )) {
      final text = IngredientLineParser.clean(heading.text);
      if (text.length > 45 || !_ingredientsHeading.hasMatch(text)) continue;

      // <p><strong>Ингредиенты:</strong></p> — поднимаемся до блока.
      var anchor = heading;
      while (anchor.nextElementSibling == null &&
          anchor.parent != null &&
          anchor.parent!.localName != 'body') {
        anchor = anchor.parent!;
      }

      final ingredients = <RecipeIngredient>[];
      var node = anchor.nextElementSibling;
      for (var hops = 0; node != null && hops < 5; hops++) {
        if (_headingTags.contains(node.localName) && hops > 0) break;
        final list = node.localName == 'ul' || node.localName == 'ol'
            ? node
            : node.querySelector('ul, ol');
        if (list != null) {
          for (final li in list.querySelectorAll('li')) {
            _addIngredient(ingredients, li.text, strict: false);
          }
        } else {
          // Ингредиенты строками через <br> / <p>.
          for (final line in blockText(node).split('\n')) {
            _addIngredient(ingredients, line);
          }
        }
        if (ingredients.length >= 2 && list != null) break;
        node = node.nextElementSibling;
      }
      if (ingredients.length >= 2) {
        return RecipeEntity(
          title: _documentTitle(document),
          imageUrl: _metaContent(document, 'og:image'),
          sourceUrl: url,
          ingredients: _dedupeIngredients(ingredients),
          extractor: 'heading',
        );
      }
    }
    return null;
  }

  Uri? _findRecipeLink(dom.Document document, Uri pageUri) {
    final host = pageUri.host.toLowerCase();
    if (!host.endsWith('food.ru') &&
        !host.endsWith('iamcook.ru') &&
        !host.endsWith('allrecipes.com')) {
      return null;
    }
    for (final link in document.querySelectorAll('a[href]')) {
      final href = link.attributes['href'];
      if (href == null || href.isEmpty) continue;
      final candidate = pageUri.resolve(href);
      if (candidate.host != pageUri.host) continue;
      final path = candidate.path.toLowerCase();
      if (path.contains('/recipe') && path != pageUri.path) return candidate;
    }
    return null;
  }

  RecipeEntity _fromHtmlHeuristics(dom.Document document, String sourceUrl) {
    final ingredients = <RecipeIngredient>[];
    const selectors = [
      '.ingredients li',
      '.recipe-ingredients li',
      '.recipeIngredient',
      '.recipe-ingredient',
      '.ingredient',
      '[class*="ingredient"] li',
      '[id*="ingredient"] li',
      '[class*="ingredients"] li',
      '[id*="ingredients"] li',
    ];
    for (final selector in selectors) {
      for (final element in document.querySelectorAll(selector)) {
        _addIngredient(ingredients, element.text, strict: false);
      }
      if (ingredients.length >= 2) break;
    }
    return RecipeEntity(
      title: _documentTitle(document),
      imageUrl: _metaContent(document, 'og:image'),
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
      extractor: 'heuristic',
    );
  }

  void _addIngredient(
    List<RecipeIngredient> target,
    String raw, {
    bool strict = true,
  }) {
    final cleaned = IngredientLineParser.clean(raw);
    if (!IngredientLineParser.looksLikeIngredient(cleaned, strict: strict)) {
      return;
    }
    final parsed = IngredientLineParser.parse(cleaned);
    if (parsed.name.trim().isNotEmpty) target.add(parsed);
  }

  //! --- AI ---

  Future<RecipeEntity> _normalizeWithAi({
    required dom.Document? document,
    required _Candidate candidate,
    required String sourceUrl,
    required String languageCode,
  }) async {
    final recipe = candidate.recipe;
    if (aiParser == null) return recipe;
    if (candidate.trusted && isCleanFor(recipe, languageCode)) return recipe;

    final input = _buildAiInput(
      document,
      recipe,
      maxText: candidate.trusted ? 5000 : 10000,
    );
    try {
      final aiRecipe = await aiParser!.parse(
        pageText: input.toText(),
        sourceUrl: sourceUrl,
        languageCode: languageCode,
      );
      if (aiRecipe == null || aiRecipe.ingredients.isEmpty) return recipe;
      // AI не имеет права выбросить почти половину надёжного списка.
      final minimum = (recipe.ingredients.length * 0.6).ceil();
      if (candidate.trusted && aiRecipe.ingredients.length < minimum) {
        return recipe;
      }
      return _mergeRecipeMetadata(
        aiRecipe,
        recipe,
        sourceUrl,
      ).copyWith(extractor: '${recipe.extractor ?? 'html'}+ai');
    } catch (_) {
      return recipe;
    }
  }

  /// Данные уже «чистые» для языка пользователя: названия на нужном
  /// алфавите и без хвостов вида «, finely chopped». Тогда AI не нужен.
  static bool isCleanFor(RecipeEntity recipe, String languageCode) {
    final lang = languageCode.toLowerCase();
    final cyrillic = RegExp(r'[а-яё]', caseSensitive: false, unicode: true);
    final latin = RegExp(r'[a-z]', caseSensitive: false);
    bool scriptOk(String name) {
      if (lang.startsWith('ru')) return cyrillic.hasMatch(name);
      if (lang.startsWith('en')) {
        return latin.hasMatch(name) && !cyrillic.hasMatch(name);
      }
      return false; // Остальные языки — переводим через AI.
    }

    if (recipe.ingredients.isEmpty) return false;
    final clean = recipe.ingredients.where((i) {
      final name = i.name.trim();
      return scriptOk(name) &&
          !name.contains(',') &&
          name.length <= 40 &&
          name.split(' ').length <= 5;
    }).length;
    return clean >= recipe.ingredients.length * 0.8;
  }

  RecipeEntity _mergeRecipeMetadata(
    RecipeEntity normalized,
    RecipeEntity candidate,
    String sourceUrl,
  ) {
    return RecipeEntity(
      title: normalized.title.trim().isEmpty
          ? candidate.title
          : normalized.title,
      imageUrl: normalized.imageUrl ?? candidate.imageUrl,
      servings: normalized.servings ?? candidate.servings,
      foodEmoji: normalized.foodEmoji ?? candidate.foodEmoji,
      sourceUrl: sourceUrl,
      ingredients: normalized.ingredients,
      extractor: normalized.extractor ?? candidate.extractor,
    );
  }

  AiRecipeInput _buildAiInput(
    dom.Document? document,
    RecipeEntity heuristicRecipe, {
    required int maxText,
  }) {
    final root = document == null
        ? null
        : document.querySelector('article') ??
              document.querySelector('main') ??
              document.body;
    return AiRecipeInput(
      title: heuristicRecipe.title,
      candidateIngredients: heuristicRecipe.ingredients
          .map((e) => e.raw)
          .toList(),
      readableText: focusText(
        root == null ? '' : blockText(root, skipChrome: true),
        maxCharacters: maxText,
      ),
    );
  }

  //! --- Финальная сборка ---

  RecipeEntity _finalize(RecipeEntity recipe, String languageCode) {
    final ingredients = _dedupeIngredients(recipe.ingredients)
        .map(
          (i) => i.copyWith(
            name: _capitalize(i.name),
            unit: RecipeUnits.localize(i.unit, languageCode),
          ),
        )
        .toList(growable: false);
    var title = _cleanTitle(recipe.title);
    if (title.isEmpty) {
      title = languageCode.startsWith('ru') ? 'Рецепт' : 'Recipe';
    }
    return RecipeEntity(
      title: title,
      imageUrl: recipe.imageUrl,
      servings: recipe.servings,
      foodEmoji: recipe.foodEmoji ?? fallbackFoodEmoji(title, ingredients),
      sourceUrl: recipe.sourceUrl,
      ingredients: ingredients,
      extractor: recipe.extractor,
    );
  }

  /// «Борщ | Едим Дома» → «Борщ». Тире не режем: «Борщ — классика».
  static String _cleanTitle(String raw) {
    final title = IngredientLineParser.clean(_plain(raw));
    final pipe = title.indexOf(' | ');
    return pipe > 3 ? title.substring(0, pipe).trim() : title;
  }

  static String _capitalize(String value) {
    final name = value.trim();
    if (name.isEmpty) return name;
    final first = String.fromCharCode(name.runes.first);
    return '${first.toUpperCase()}${name.substring(first.length)}';
  }

  static String fallbackFoodEmoji(
    String title,
    List<RecipeIngredient> ingredients,
  ) {
    final titleText = title.toLowerCase();
    final text = '$titleText ${ingredients.map((e) => e.name).join(' ')}'
        .toLowerCase();
    const byTitle = <String, List<String>>{
      '🍲': ['суп', 'борщ', 'щи', 'солянк', 'soup', 'stew', 'рагу'],
      '🍝': ['паст', 'макарон', 'спагетти', 'pasta', 'spaghetti', 'лазань'],
      '🥗': ['салат', 'salad'],
      '🍕': ['пицц', 'pizza'],
      '🍰': ['торт', 'cake', 'десерт', 'чизкейк', 'cheesecake'],
      '🧁': ['кекс', 'маффин', 'muffin', 'cupcake'],
      '🍪': ['печень', 'cookie'],
      '🥞': ['блин', 'олад', 'pancake', 'сырник'],
      '🍞': ['хлеб', 'bread', 'булочк'],
      '🥟': ['пельмен', 'вареник', 'dumpling', 'манты', 'хинкали'],
      '🍛': ['плов', 'карри', 'curry', 'ризотто', 'risotto'],
      '🍔': ['бургер', 'burger'],
      '🌮': ['тако', 'taco', 'буррито', 'шаурм'],
      '🍳': ['омлет', 'яичниц', 'omelet', 'шакшук'],
      '🥣': ['каша', 'овсян', 'porridge', 'granola'],
    };
    for (final entry in byTitle.entries) {
      if (entry.value.any(titleText.contains)) return entry.key;
    }
    const byIngredients = <String, List<String>>{
      '🍗': ['кур', 'chicken', 'индейк', 'turkey'],
      '🥩': ['говядин', 'свинин', 'beef', 'pork', 'стейк', 'steak'],
      '🐟': ['рыб', 'лосос', 'fish', 'salmon', 'тунец', 'tuna'],
    };
    for (final entry in byIngredients.entries) {
      if (entry.value.any(text.contains)) return entry.key;
    }
    const fallback = ['🍲', '🍝', '🥗', '🍳', '🥘', '🍚'];
    return fallback[title.hashCode.abs() % fallback.length];
  }

  //! --- Текст ---

  static const _blockTags = {
    'p', 'div', 'li', 'ul', 'ol', 'br', 'tr', 'table', 'section', 'article', //
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'dt', 'dd', 'blockquote', 'pre',
    'figure', 'figcaption', 'main', 'header', 'footer',
  };

  static const _skipTags = {'script', 'style', 'noscript', 'template', 'svg'};

  static const _chromeTags = {
    'nav', 'header', 'footer', 'aside', 'form', 'button', 'iframe', //
    'canvas', 'dialog',
  };

  /// Текст элемента с переводами строк на границах блоков — в отличие от
  /// `element.text`, где `<li>` и `<p>` склеиваются в одну строку.
  static String blockText(dom.Node? root, {bool skipChrome = false}) {
    if (root == null) return '';
    final buffer = StringBuffer();
    void walk(dom.Node node) {
      if (node is dom.Text) {
        buffer.write(node.text);
        return;
      }
      if (node is dom.Element) {
        final tag = node.localName ?? '';
        if (_skipTags.contains(tag)) return;
        if (skipChrome && _chromeTags.contains(tag)) return;
        final block = _blockTags.contains(tag);
        if (block) buffer.write('\n');
        for (final child in node.nodes) {
          walk(child);
        }
        if (block) buffer.write('\n');
        if (tag == 'td' || tag == 'th') buffer.write(' ');
        return;
      }
      for (final child in node.nodes) {
        walk(child);
      }
    }

    walk(root);
    return buffer
        .toString()
        .split('\n')
        .map(IngredientLineParser.clean)
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  /// Окно текста вокруг раздела ингредиентов: начало статьи — обычно
  /// «история из жизни», а не рецепт.
  static String focusText(String text, {required int maxCharacters}) {
    if (text.length <= maxCharacters) return text;
    final match = RegExp(
      r'ингредиенты|продукты|понадобится|ingredients|you.ll need',
      caseSensitive: false,
    ).firstMatch(text);
    final start = match == null
        ? 0
        : (match.start - 800).clamp(0, text.length - maxCharacters);
    return text.substring(start, start + maxCharacters);
  }

  static String _plain(String value) {
    if (!value.contains('<') && !value.contains('&')) return value.trim();
    return (html_parser.parseFragment(value).text ?? value).trim();
  }

  List<RecipeIngredient> _dedupeIngredients(Iterable<RecipeIngredient> items) {
    final result = <RecipeIngredient>[];
    final keys = <String>{};
    for (final item in items) {
      final key = [
        item.name.toLowerCase().trim(),
        item.quantity ?? '',
        RecipeUnits.canonical(item.unit) ?? item.unit ?? '',
      ].join('|');
      if (keys.add(key)) result.add(item);
    }
    return result;
  }

  String _documentTitle(dom.Document document) {
    return _metaContent(document, 'og:title') ??
        document.querySelector('h1')?.text.trim() ??
        document.querySelector('title')?.text.trim() ??
        '';
  }

  String? _metaContent(dom.Document document, String property) {
    final element =
        document.querySelector('meta[property="$property"]') ??
        document.querySelector('meta[name="$property"]');
    final value = element?.attributes['content']?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final s = (value is String ? value : value.toString()).trim();
    return s.isEmpty ? null : s;
  }
}

extension on String {
  String? get nullIfEmpty => trim().isEmpty ? null : this;
}

class AiRecipeInput {
  const AiRecipeInput({
    required this.title,
    required this.candidateIngredients,
    required this.readableText,
  });

  final String? title;
  final List<String> candidateIngredients;
  final String readableText;

  String toText() {
    final buffer = StringBuffer();
    if (title != null && title!.isNotEmpty) {
      buffer.writeln('TITLE:\n$title');
    }
    if (candidateIngredients.isNotEmpty) {
      buffer.writeln('\nCANDIDATE INGREDIENTS:');
      for (final ingredient in candidateIngredients) {
        buffer.writeln('- $ingredient');
      }
    }
    if (readableText.isNotEmpty) {
      buffer.writeln('\nPAGE TEXT:\n$readableText');
    }
    return buffer.toString();
  }
}

class RecipeScrapeException implements Exception {
  final String message;
  final RecipeScrapeErrorKind kind;

  const RecipeScrapeException(
    this.message, {
    this.kind = RecipeScrapeErrorKind.noIngredients,
  });

  @override
  String toString() => 'RecipeScrapeException: $message';
}
