import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:pora/core/features/recipe/data/datasource/ai_recipe_parser.dart';
import 'package:pora/core/features/recipe/data/datasource/youtube_recipe_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/internal/di/export.dart';

abstract class RecipeScraper {
  Future<RecipeEntity> scrape(String url, {String languageCode = 'ru'});
}

class HttpRecipeScraper implements RecipeScraper {
  HttpRecipeScraper({
    http.Client? client,
    this.aiParser,
    YouTubeRecipeParser? youtubeParser,
  }) : _client = client ?? http.Client(),
       _youtubeParser = youtubeParser ?? YouTubeRecipeParser(client: client);

  final http.Client _client;
  final AiRecipeParser? aiParser;
  final YouTubeRecipeParser _youtubeParser;

  static const String _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) '
      'Version/17.0 Mobile/15E148 Safari/604.1';

  @override
  Future<RecipeEntity> scrape(String url, {String languageCode = 'ru'}) async {
    final normalized = _normalizeUrl(url);

    if (YouTubeUrl.isYouTube(normalized)) {
      return _scrapeYouTube(normalized, languageCode: languageCode);
    }

    return _scrapeHtml(normalized, languageCode: languageCode);
  }

  Future<RecipeEntity> _scrapeYouTube(
    Uri uri, {
    required String languageCode,
  }) async {
    final result = await _youtubeParser.parse(uri, languageCode: languageCode);

    if (result == null) {
      throw const RecipeScrapeException(
        'Не удалось извлечь рецепт из YouTube.',
      );
    }

    return result;
  }

  Future<RecipeEntity> _scrapeHtml(
    Uri uri, {
    required String languageCode,
    bool allowIndexFallback = true,
  }) async {
    // Step 0: RecipeStripper may already have a clean structured recipe.
    final stripped = await _fetchRecipeStripper(uri);
    if (stripped != null && stripped.ingredients.isNotEmpty) {
      final normalized = await _normalizeWithAi(
        document: html_parser.parse(''),
        candidate: stripped,
        sourceUrl: uri.toString(),
        languageCode: languageCode,
      );
      return normalized ?? _withRecipeFallbacks(stripped, uri.toString());
    }

    final response = await _fetchHtml(uri);

    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw RecipeScrapeException('HTTP ${response.statusCode} for $uri');
    }

    final finalUrl = response.request?.url.toString() ?? uri.toString();

    final body = _decodeBody(response);
    final document = html_parser.parse(body);

    // Tiers 1-3 produce raw evidence. It is normalized below before the app
    // receives a RecipeEntity.
    final jsonLd = _tryJsonLd(document, finalUrl);
    final microdata = _fromMicrodata(document, finalUrl);
    final siteRecipe = _fromSiteAdapter(document, finalUrl);
    final htmlRecipe = _fromHtmlHeuristics(document, finalUrl);
    var candidate = _selectCandidate([
      ?jsonLd,
      ?microdata,
      ?siteRecipe,
      htmlRecipe,
    ]);

    if (candidate.ingredients.length < 2) {
      final upstream = await _fetchJustTheRecipe(uri);
      if (upstream != null && upstream.ingredients.isNotEmpty) {
        candidate = upstream;
      }
    }

    if (candidate.ingredients.isEmpty && allowIndexFallback) {
      final recipeLink = _findRecipeLink(document, uri);
      if (recipeLink != null) {
        try {
          return await _scrapeHtml(
            recipeLink,
            languageCode: languageCode,
            allowIndexFallback: false,
          );
        } on RecipeScrapeException {
          // Continue to AI fallback for pages whose first link is stale.
        }
      }
    }

    if (candidate.ingredients.isNotEmpty) {
      final normalized = await _normalizeWithAi(
        document: document,
        candidate: candidate,
        sourceUrl: finalUrl,
        languageCode: languageCode,
      );
      return normalized ?? _withRecipeFallbacks(candidate, finalUrl);
    }

    // Tier 4: AI fallback for completely unstructured pages.
    if (aiParser != null) {
      final input = _buildAiInput(document, candidate);

      if (input.readableText.isNotEmpty) {
        try {
          final aiRecipe = await aiParser!.parse(
            pageText: input.toText(),
            sourceUrl: finalUrl,
            languageCode: languageCode,
          );

          if (aiRecipe != null && aiRecipe.ingredients.isNotEmpty) {
            return _mergeRecipeMetadata(aiRecipe, candidate, finalUrl);
          }
        } catch (_) {
          // A provider failure must not discard a valid deterministic result.
        }
      }
    }

    throw const RecipeScrapeException(
      'Не удалось найти ингредиенты на странице.',
    );
  }

  RecipeEntity _withRecipeFallbacks(RecipeEntity recipe, String sourceUrl) {
    return recipe.foodEmoji == null
        ? _mergeRecipeMetadata(recipe, recipe, sourceUrl)
        : recipe;
  }

  Future<RecipeEntity?> _normalizeWithAi({
    required dom.Document document,
    required RecipeEntity candidate,
    required String sourceUrl,
    required String languageCode,
  }) async {
    if (aiParser == null) return null;
    final input = _buildAiInput(document, candidate);
    if (input.readableText.isEmpty && input.candidateIngredients.isEmpty) {
      return null;
    }
    try {
      final aiRecipe = await aiParser!.parse(
        pageText: input.toText(),
        sourceUrl: sourceUrl,
        languageCode: languageCode,
      );
      if (aiRecipe == null || aiRecipe.ingredients.isEmpty) return null;
      return _mergeRecipeMetadata(aiRecipe, candidate, sourceUrl);
    } catch (_) {
      return null;
    }
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
      foodEmoji:
          normalized.foodEmoji ??
          candidate.foodEmoji ??
          _fallbackFoodEmoji(candidate),
      sourceUrl: sourceUrl,
      ingredients: normalized.ingredients
          .map(_capitalizeIngredient)
          .toList(growable: false),
    );
  }

  RecipeIngredient _capitalizeIngredient(RecipeIngredient ingredient) {
    final name = ingredient.name.trim();
    if (name.isEmpty) return ingredient;
    final first = String.fromCharCode(name.runes.first);
    return RecipeIngredient(
      name: '${first.toUpperCase()}${name.substring(first.length)}',
      quantity: ingredient.quantity,
      unit: ingredient.unit,
      note: ingredient.note,
      raw: ingredient.raw,
    );
  }

  String _fallbackFoodEmoji(RecipeEntity recipe) {
    final text =
        '${recipe.title} ${recipe.ingredients.map((e) => e.name).join(' ')}'
            .toLowerCase();
    if (text.contains('суп') || text.contains('soup')) return '🍲';
    if (text.contains('паст') ||
        text.contains('макарон') ||
        text.contains('pasta')) {
      return '🍝';
    }
    if (text.contains('салат') || text.contains('salad')) return '🥗';
    if (text.contains('пицц') || text.contains('pizza')) return '🍕';
    if (text.contains('торт') ||
        text.contains('cake') ||
        text.contains('десерт')) {
      return '🍰';
    }
    if (text.contains('хлеб') || text.contains('bread')) return '🍞';
    if (text.contains('кур') || text.contains('chicken')) return '🍗';
    if (text.contains('рыб') || text.contains('fish')) return '🐟';
    const fallback = ['🍲', '🍝', '🥗', '🍳', '🥘', '🍚'];
    return fallback[recipe.title.hashCode.abs() % fallback.length];
  }

  RecipeEntity _selectCandidate(List<RecipeEntity> candidates) {
    return candidates.reduce((best, current) {
      if (current.ingredients.length > best.ingredients.length) return current;
      if (current.ingredients.length == best.ingredients.length &&
          current.title.length > best.title.length) {
        return current;
      }
      return best;
    });
  }

  Future<http.Response> _fetchHtml(Uri uri) async {
    return _client
        .get(
          uri,
          headers: {
            'User-Agent': _userAgent,
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'ru,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Cache-Control': 'no-cache',
          },
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<RecipeEntity?> _fetchRecipeStripper(Uri sourceUri) async {
    final endpoint = Uri.https(dotenv.get('AI_RECIPE_SCRAPPER_URL'), '/', {
      'url': sourceUri.toString(),
    });
    try {
      final response = await _client
          .get(
            endpoint,
            headers: {
              'User-Agent': _userAgent,
              'Accept': 'text/html,application/xhtml+xml',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final body = _decodeBody(response);
      final document = html_parser.parse(body);
      final sourceUrl = sourceUri.toString();
      final jsonLd = _tryJsonLd(document, sourceUrl);
      final microdata = _fromMicrodata(document, sourceUrl);
      final siteRecipe = _fromSiteAdapter(document, sourceUrl);
      final htmlRecipe = _fromHtmlHeuristics(document, sourceUrl);
      final candidate = _selectCandidate([
        ?jsonLd,
        ?microdata,
        ?siteRecipe,
        htmlRecipe,
      ]);
      return candidate.ingredients.isEmpty ? null : candidate;
    } catch (_) {
      return null;
    }
  }

  Future<RecipeEntity?> _fetchJustTheRecipe(Uri sourceUri) async {
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
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final rawIngredients = map['ingredients'];
      if (rawIngredients is! List) return null;

      final ingredients = <RecipeIngredient>[];
      for (final raw in rawIngredients) {
        if (raw is! Map) continue;
        final name = _asString(raw['name']);
        if (name == null || name.isEmpty) continue;
        final ingredient =
            _parseRussianFoodIngredient(name) ?? _parseIngredientLine(name);
        if (ingredient.name.trim().isNotEmpty) ingredients.add(ingredient);
      }
      final unique = _dedupeIngredients(ingredients);
      if (unique.isEmpty) return null;

      final images = map['imageUrls'];
      final image = images is List && images.isNotEmpty
          ? _asString(images.first)
          : null;
      return RecipeEntity(
        title: _asString(map['name']) ?? 'Рецепт',
        imageUrl: image,
        servings: _asString(map['servings']),
        sourceUrl: sourceUri.toString(),
        ingredients: unique,
      );
    } catch (_) {
      return null;
    }
  }

  String _decodeBody(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';

    final charsetMatch = RegExp(
      r'charset=([^\s;]+)',
      caseSensitive: false,
    ).firstMatch(contentType);

    final bytes = response.bodyBytes;
    var charset = charsetMatch?.group(1)?.toLowerCase();
    if (charset == null) {
      final probe = utf8.decode(
        bytes.take(4096).toList(),
        allowMalformed: true,
      );
      charset = RegExp(
        r'''charset\s*=\s*["']?([\w-]+)''',
        caseSensitive: false,
      ).firstMatch(probe)?.group(1)?.toLowerCase();
    }

    if (charset == 'windows-1251' || charset == 'cp1251') {
      return _decodeWindows1251(bytes);
    }

    if (charset == 'utf-8' || charset == null || charset == 'utf8') {
      return utf8.decode(bytes, allowMalformed: true);
    }

    // dart:io doesn't provide arbitrary charset decoding.
    // UTF-8 fallback remains the safest client-only option.
    return utf8.decode(bytes, allowMalformed: true);
  }

  String _decodeWindows1251(List<int> bytes) {
    const middle =
        'ЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—™љ›њќћџ ЎўЈ¤Ґ¦§Ё©Є«¬­®Ї°±Ііґµ¶·ё№є»јЅѕї';
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte < 0x80) {
        buffer.writeCharCode(byte);
      } else if (byte >= 0xC0) {
        buffer.writeCharCode(0x0410 + byte - 0xC0);
      } else {
        final index = byte - 0x80;
        buffer.write(index < middle.length ? middle[index] : '\uFFFD');
      }
    }
    return buffer.toString();
  }

  Uri _normalizeUrl(String raw) {
    final value = raw.trim();

    if (value.isEmpty) {
      throw const RecipeScrapeException('Пустой URL.');
    }

    final normalized =
        value.startsWith('http://') || value.startsWith('https://')
        ? value
        : 'https://$value';

    final uri = Uri.tryParse(normalized);

    if (uri == null || uri.host.isEmpty) {
      throw const RecipeScrapeException('Некорректный URL.');
    }

    return uri;
  }

  // ---------------------------------------------------------------------------
  // JSON-LD
  // ---------------------------------------------------------------------------

  RecipeEntity? _tryJsonLd(dom.Document document, String sourceUrl) {
    final scripts = document.querySelectorAll(
      'script[type="application/ld+json"]',
    );

    for (final script in scripts) {
      final raw = script.text.trim();

      if (raw.isEmpty) {
        continue;
      }

      final decoded = _decodeJsonLd(raw);

      if (decoded == null) {
        continue;
      }

      final recipe = _findRecipeNode(decoded);

      if (recipe == null) {
        continue;
      }

      final ingredients = _extractIngredients(recipe['recipeIngredient']);

      if (ingredients.isEmpty) {
        continue;
      }

      return RecipeEntity(
        title: _asString(recipe['name']) ?? _documentTitle(document),
        imageUrl:
            _extractImageUrl(recipe['image']) ??
            _metaContent(document, 'og:image'),
        servings: _asString(recipe['recipeYield']),
        sourceUrl: sourceUrl,
        ingredients: ingredients,
      );
    }

    return null;
  }

  dynamic _decodeJsonLd(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {}

    // Некоторые сайты кладут комментарии вокруг JSON.
    final objectStart = raw.indexOf('{');
    final objectEnd = raw.lastIndexOf('}');
    final arrayStart = raw.indexOf('[');
    final arrayEnd = raw.lastIndexOf(']');
    final useArray =
        arrayStart >= 0 &&
        arrayEnd > arrayStart &&
        (objectStart < 0 || arrayStart < objectStart);
    final start = useArray ? arrayStart : objectStart;
    final end = useArray ? arrayEnd : objectEnd;

    if (start >= 0 && end > start) {
      try {
        return jsonDecode(raw.substring(start, end + 1));
      } catch (_) {}
    }

    return null;
  }

  RecipeEntity? _fromMicrodata(dom.Document document, String sourceUrl) {
    final recipeRoot = document.querySelector(
      '[itemscope][itemtype*="Recipe"]',
    );
    final ingredients = <RecipeIngredient>[];
    final ingredientElements = (recipeRoot ?? document).querySelectorAll(
      '[itemprop="recipeIngredient"]',
    );
    for (final element in ingredientElements) {
      _addIngredientIfValid(ingredients, element.text);
    }
    if (ingredients.isEmpty) return null;

    final title =
        recipeRoot?.querySelector('[itemprop="name"]')?.text.trim() ??
        _documentTitle(document);
    final image =
        recipeRoot
            ?.querySelector('[itemprop="image"]')
            ?.attributes['content'] ??
        recipeRoot?.querySelector('[itemprop="image"]')?.attributes['src'] ??
        _metaContent(document, 'og:image');
    final servings = recipeRoot
        ?.querySelector('[itemprop="recipeYield"]')
        ?.text
        .trim();

    return RecipeEntity(
      title: title,
      imageUrl: image,
      servings: servings?.isEmpty == true ? null : servings,
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
    );
  }

  Map<String, dynamic>? _findRecipeNode(dynamic node) {
    if (node is List) {
      for (final child in node) {
        final result = _findRecipeNode(child);

        if (result != null) {
          return result;
        }
      }

      return null;
    }

    if (node is Map) {
      final map = Map<String, dynamic>.from(node);

      final type = map['@type'];

      final isRecipe =
          type == 'Recipe' || (type is List && type.contains('Recipe'));

      if (isRecipe) {
        return map;
      }

      final graph = map['@graph'];

      if (graph != null) {
        return _findRecipeNode(graph);
      }

      for (final value in map.values) {
        final nested = _findRecipeNode(value);

        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  List<RecipeIngredient> _extractIngredients(dynamic raw) {
    final values = raw is List
        ? raw
        : raw is String
        ? [raw]
        : const [];

    final result = <RecipeIngredient>[];

    for (final item in values) {
      final text = item is String
          ? item
          : item is Map
          ? _asString(item['name']) ?? _asString(item['value'])
          : null;
      if (text == null) continue;

      final cleaned = _cleanText(text);

      if (cleaned.isEmpty) {
        continue;
      }

      result.add(_parseIngredientLine(cleaned));
    }

    return _dedupeIngredients(result);
  }

  String? _extractImageUrl(dynamic raw) {
    if (raw is String) {
      return raw.trim();
    }

    if (raw is List && raw.isNotEmpty) {
      return _extractImageUrl(raw.first);
    }

    if (raw is Map) {
      return _asString(raw['url']);
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // HTML
  // ---------------------------------------------------------------------------

  RecipeEntity? _fromSiteAdapter(dom.Document document, String sourceUrl) {
    final host = Uri.tryParse(sourceUrl)?.host.toLowerCase() ?? '';
    final selectors = <String>[];
    var sectionPattern = RegExp(
      r'ingredients?|ингредиенты|продукты|состав',
      caseSensitive: false,
    );

    if (host.endsWith('russianfood.com')) {
      sectionPattern = RegExp(r'продукты|ингредиенты', caseSensitive: false);
      selectors.addAll([
        '.ingr tr',
        '.ingr_tr_0',
        '.ingr_tr_1',
        '.ingredients-list li',
        '.recipe_list li',
      ]);
    } else if (host.endsWith('food.ru')) {
      selectors.addAll([
        '[data-ingredient]',
        '[class*="ingredient"] li',
        '[class*="Ingredient"]',
      ]);
    } else if (host.endsWith('povar.ru')) {
      sectionPattern = RegExp(r'ингредиенты|продукты', caseSensitive: false);
      selectors.addAll([
        '.ingredients-list li',
        '.ingredients li',
        '.ingredient',
      ]);
    } else if (host.endsWith('iamcook.ru')) {
      selectors.addAll([
        '.ingredients-list li',
        '.ingredients li',
        '[itemprop="recipeIngredient"]',
      ]);
    } else if (host.endsWith('recipetineats.com')) {
      selectors.addAll([
        '.wprm-recipe-ingredient',
        '.tasty-recipe-ingredients li',
      ]);
    } else if (host.endsWith('allrecipes.com')) {
      selectors.addAll([
        '[data-ingredient-name]',
        '[data-ingredient-quantity]',
        '.mntl-structured-ingredients__list-item',
      ]);
    } else {
      return null;
    }

    final ingredients = <RecipeIngredient>[];
    if (host.endsWith('russianfood.com')) {
      for (final table in document.querySelectorAll('table')) {
        final classes =
            table.attributes['class']?.split(RegExp(r'\s+')) ?? const [];
        if (!classes.contains('ingr')) continue;
        for (final row in table.querySelectorAll('tr')) {
          _addIngredientIfValid(ingredients, row.text);
        }
      }
    }
    for (final selector in selectors) {
      for (final element in document.querySelectorAll(selector)) {
        final value = element.attributes['data-ingredient'] ?? element.text;
        _addIngredientIfValid(ingredients, value);
      }
      if (ingredients.length >= 2) break;
    }

    if (host.endsWith('russianfood.com')) {
      ingredients.addAll(_parseRussianFoodIngredients(document));
    }

    if (ingredients.length < 2) {
      final text = _cleanText(document.body?.text ?? '');
      final match = sectionPattern.firstMatch(text);
      if (match != null) {
        final block = text
            .substring(match.end)
            .split(
              RegExp(
                r'(?:directions?|instructions?|приготовление|пошаговый|method|nutrition|notes?)',
                caseSensitive: false,
              ),
            )
            .first;
        for (final line in block.split(RegExp(r'\s*(?:\n|•|·)\s*'))) {
          _addIngredientIfValid(ingredients, line);
        }
      }
    }

    if (ingredients.isEmpty) return null;
    return RecipeEntity(
      title: _documentTitle(document),
      imageUrl: _metaContent(document, 'og:image'),
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
    );
  }

  Uri? _findRecipeLink(dom.Document document, Uri pageUri) {
    final host = pageUri.host.toLowerCase();
    if (!host.endsWith('food.ru') &&
        !host.endsWith('iamcook.ru') &&
        !host.endsWith('allrecipes.com')) {
      return null;
    }

    final links = document.querySelectorAll('a[href]');
    for (final link in links) {
      final href = link.attributes['href'];
      if (href == null || href.isEmpty) continue;
      final candidate = pageUri.resolve(href);
      if (candidate.host != pageUri.host) continue;
      final path = candidate.path.toLowerCase();
      if (path.contains('/recipe') && path != pageUri.path) {
        return candidate;
      }
    }
    return null;
  }

  RecipeEntity _fromHtmlHeuristics(dom.Document document, String sourceUrl) {
    final title = _documentTitle(document);

    final image = _metaContent(document, 'og:image');

    final ingredients = <RecipeIngredient>[];

    // 1. Сначала пробуем стандартные структуры.
    for (final element in document.querySelectorAll(
      '[itemprop="recipeIngredient"]',
    )) {
      _addIngredientIfValid(ingredients, element.text);
    }

    const selectors = [
      '.ingredient',
      '.ingredients li',
      '.recipe-ingredients li',
      '.recipeIngredient',
      '.recipe-ingredient',
      '[class*="ingredient"] li',
      '[id*="ingredient"] li',
      '[class*="ingredients"] li',
      '[id*="ingredients"] li',
    ];

    for (final selector in selectors) {
      for (final element in document.querySelectorAll(selector)) {
        _addIngredientIfValid(ingredients, element.text);
      }

      if (ingredients.length >= 2) {
        break;
      }
    }

    // 2. RussianFood.
    if (ingredients.length < 2) {
      final russianFoodIngredients = _parseRussianFoodIngredients(document);

      ingredients.addAll(russianFoodIngredients);
    }

    return RecipeEntity(
      title: title,
      imageUrl: image,
      sourceUrl: sourceUrl,
      ingredients: _dedupeIngredients(ingredients),
    );
  }

  List<RecipeIngredient> _parseRussianFoodIngredients(dom.Document document) {
    final result = <RecipeIngredient>[];

    final text = document.body?.text ?? '';

    if (text.isEmpty) {
      return result;
    }

    final normalized = text
        .replaceAll('\u00A0', ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final startMatch = RegExp(
      r'Продукты\s*(?:\([^)]*\))?',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(normalized);

    if (startMatch == null) {
      return result;
    }

    final start = startMatch.end;

    final endMatch = RegExp(
      r'Пошаговый\s+(?:фото\s+)?рецепт',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(normalized.substring(start));

    final end = endMatch == null ? normalized.length : start + endMatch.start;

    final block = normalized.substring(start, end);

    final lines = block
        .split('\n')
        .map(_cleanText)
        .where((line) => line.isNotEmpty)
        .toList();

    for (final line in lines) {
      final ingredient = _parseRussianFoodIngredient(line);

      if (ingredient != null) {
        result.add(ingredient);
      }
    }

    return result;
  }

  RecipeIngredient? _parseRussianFoodIngredient(String raw) {
    final cleaned = _cleanText(raw.replaceAll('\u00A0', ' ').trim());

    if (cleaned.isEmpty) {
      return null;
    }

    // RussianFood:
    // Капуста белокочанная - 1,2 кг
    // Фарш свино-говяжий - 600 г
    // Соль - 1/2 ч. ложки (по вкусу)

    final match = RegExp(
      r'^(?<name>.+?)'
      r'\s*[-–—]\s*'
      r'(?<quantity>'
      r'\d+(?:[.,]\d+)?'
      r'|\d+\s*/\s*\d+'
      r')'
      r'\s*'
      r'(?<unit>.+?)'
      r'(?:\s*\((?<note>[^)]*)\))?'
      r'$',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(cleaned);

    if (match == null) {
      // Например:
      // Огурцы - по вкусу

      final tasteMatch = RegExp(
        r'^(?<name>.+?)'
        r'\s*[-–—]\s*'
        r'(?<note>по вкусу|по желанию)$',
        caseSensitive: false,
        unicode: true,
      ).firstMatch(cleaned);

      if (tasteMatch != null) {
        return RecipeIngredient(
          name: tasteMatch.namedGroup('name')!.trim(),
          raw: raw,
          note: tasteMatch.namedGroup('note'),
        );
      }

      return null;
    }

    final name = match.namedGroup('name')!.trim();

    final quantity = match.namedGroup('quantity');

    final rawUnit = match.namedGroup('unit')?.trim();

    final note = match.namedGroup('note')?.trim();

    return RecipeIngredient(
      name: name,
      quantity: quantity,
      unit: _normalizeUnit(rawUnit),
      note: note,
      raw: raw,
    );
  }

  void _addIngredientIfValid(List<RecipeIngredient> target, String raw) {
    final cleaned = _cleanText(raw);

    if (!_looksLikeIngredient(cleaned)) {
      return;
    }

    target.add(_parseIngredientLine(cleaned));
  }

  bool _looksLikeIngredient(String value) {
    if (value.length < 2 || value.length > 300) {
      return false;
    }

    final lower = value.toLowerCase();

    const ignored = {
      'ingredients',
      'ingredient',
      'ингредиенты',
      'продукты',
      'состав',
    };

    if (ignored.contains(lower)) {
      return false;
    }

    if (RegExp(r'\d').hasMatch(value)) {
      return true;
    }

    const semanticMarkers = [
      'по вкусу',
      'по желанию',
      'for taste',
      'to taste',
      'as needed',
    ];

    return semanticMarkers.any(lower.contains);
  }

  // ---------------------------------------------------------------------------
  // AI input
  // ---------------------------------------------------------------------------

  AiRecipeInput _buildAiInput(
    dom.Document document,
    RecipeEntity heuristicRecipe,
  ) {
    final clone = html_parser.parse(document.outerHtml);

    const dropSelectors = [
      'script',
      'style',
      'noscript',
      'nav',
      'header',
      'footer',
      'aside',
      'form',
      'button',
      'iframe',
      'svg',
      'canvas',
      'template',
      'dialog',
    ];

    for (final selector in dropSelectors) {
      for (final element in clone.querySelectorAll(selector)) {
        element.remove();
      }
    }

    final root =
        clone.querySelector('article') ??
        clone.querySelector('main') ??
        clone.body ??
        clone.documentElement;

    final readableText = _cleanText(root?.text ?? '');

    return AiRecipeInput(
      title: heuristicRecipe.title,
      candidateIngredients: heuristicRecipe.ingredients
          .map((e) => e.raw)
          .toList(),
      readableText: _limitText(readableText, maxCharacters: 40_000),
    );
  }

  // ---------------------------------------------------------------------------
  // Ingredient normalization
  // ---------------------------------------------------------------------------

  static final RegExp _prefixQuantity = RegExp(
    r'^\s*'
    r'(?<quantity>'
    r'\d+(?:[.,]\d+)?'
    r'(?:\s*[-–—]\s*'
    r'\d+(?:[.,]\d+)?)?'
    r'|\d+\s*/\s*\d+'
    r')'
    r'\s*'
    r'(?<unit>грамм(?:а|ов)?|г|кг|мг|мл|л|'
    r'шт\.?|штук|кус(?:ок|ка|ки)?|'
    r'зубчик(?:а|ов)?|ст\.?\s*л\.?|'
    r'ч\.?\s*л\.?|стакан(?:а|ов)?|'
    r'банка|пуч(?:ок|ка)|'
    r'g|kg|mg|ml|l|pcs?|'
    r'tsp|tbsp|cup|cups|oz|lb)'
    r'?\s+'
    r'(?<name>.+?)'
    r'\s*$',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _suffixQuantity = RegExp(
    r'^\s*'
    r'(?<name>.+?)'
    r'\s+'
    r'(?<quantity>'
    r'\d+(?:[.,]\d+)?'
    r'(?:\s*[-–—]\s*'
    r'\d+(?:[.,]\d+)?)?'
    r'|\d+\s*/\s*\d+'
    r')'
    r'\s*'
    r'(?<unit>грамм(?:а|ов)?|г|кг|мг|мл|л|'
    r'шт\.?|штук|кус(?:ок|ка|ки)?|'
    r'зубчик(?:а|ов)?|ст\.?\s*л\.?|'
    r'ч\.?\s*л\.?|стакан(?:а|ов)?|'
    r'банка|пуч(?:ок|ка)|'
    r'g|kg|mg|ml|l|pcs?|'
    r'tsp|tbsp|cup|cups|oz|lb)'
    r'?\s*$',
    caseSensitive: false,
    unicode: true,
  );

  RecipeIngredient _parseIngredientLine(String raw) {
    final cleaned = _cleanText(raw);

    final prefix = _prefixQuantity.firstMatch(cleaned);

    if (prefix != null) {
      return RecipeIngredient(
        name: _cleanIngredientName(prefix.namedGroup('name')),
        quantity: prefix.namedGroup('quantity'),
        unit: _normalizeUnit(prefix.namedGroup('unit')),
        raw: raw,
      );
    }

    final suffix = _suffixQuantity.firstMatch(cleaned);

    if (suffix != null) {
      return RecipeIngredient(
        name: _cleanIngredientName(suffix.namedGroup('name')),
        quantity: suffix.namedGroup('quantity'),
        unit: _normalizeUnit(suffix.namedGroup('unit')),
        raw: raw,
      );
    }

    return RecipeIngredient(name: _cleanIngredientName(cleaned), raw: raw);
  }

  String _cleanIngredientName(String? value) {
    if (value == null) {
      return '';
    }

    var result = value.trim();

    result = result.replaceFirst(
      RegExp(r'^(?:of|из|для)\s+', caseSensitive: false),
      '',
    );

    return result;
  }

  String? _normalizeUnit(String? raw) {
    if (raw == null) {
      return null;
    }

    var value = raw.trim().toLowerCase();

    value = value.replaceAll('.', '').replaceAll(RegExp(r'\s+'), ' ');

    if (value.contains('кг') || value == 'kg') return 'kg';
    if (value == 'г' || value == 'g' || value.contains('грамм')) {
      return 'g';
    }

    if (value.contains('мл') || value == 'ml') return 'ml';
    if (value == 'л' || value == 'l' || value.contains('литр')) {
      return 'l';
    }

    if (value.contains('ст л') || value.contains('ст лож') || value == 'tbsp') {
      return 'tbsp';
    }

    if (value.contains('ч л') || value.contains('ч лож') || value == 'tsp') {
      return 'tsp';
    }

    if (value.contains('шт') || value.contains('штук')) {
      return 'pcs';
    }

    if (value.contains('зубчик')) {
      return 'clove';
    }

    if (value.contains('стакан')) {
      return 'cup';
    }

    if (value.contains('банка')) {
      return 'can';
    }

    if (value.contains('пучок')) {
      return 'bunch';
    }

    if (value == 'cup' || value == 'cups') return 'cup';
    if (value == 'oz') return 'oz';
    if (value == 'lb') return 'lb';

    return null;
  }

  List<RecipeIngredient> _dedupeIngredients(Iterable<RecipeIngredient> items) {
    final result = <RecipeIngredient>[];
    final keys = <String>{};

    for (final item in items) {
      final key = [
        item.name.toLowerCase().trim(),
        item.quantity ?? '',
        item.unit ?? '',
      ].join('|');

      if (keys.add(key)) {
        result.add(item);
      }
    }

    return result;
  }

  String _documentTitle(dom.Document document) {
    return _metaContent(document, 'og:title') ??
        document.querySelector('h1')?.text.trim() ??
        document.querySelector('title')?.text.trim() ??
        'Рецепт';
  }

  String? _metaContent(dom.Document document, String property) {
    final element =
        document.querySelector('meta[property="$property"]') ??
        document.querySelector('meta[name="$property"]');

    return element?.attributes['content']?.trim();
  }

  String _cleanText(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _limitText(String value, {required int maxCharacters}) {
    if (value.length <= maxCharacters) {
      return value;
    }

    return value.substring(0, maxCharacters);
  }

  String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final trimmed = value.trim();

      return trimmed.isEmpty ? null : trimmed;
    }

    return value.toString();
  }
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

    buffer.writeln('\nPAGE TEXT:\n$readableText');

    return buffer.toString();
  }
}

class RecipeScrapeException implements Exception {
  final String message;

  const RecipeScrapeException(this.message);

  @override
  String toString() => 'RecipeScrapeException: $message';
}
