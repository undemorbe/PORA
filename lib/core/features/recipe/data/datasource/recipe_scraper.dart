import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:pora/core/features/recipe/data/datasource/ai_recipe_parser.dart';
import 'package:pora/core/features/recipe/data/datasource/youtube_recipe_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

abstract class RecipeScraper {
  Future<RecipeEntity> scrape(
    String url, {
    String languageCode = 'ru',
  });
}

class HttpRecipeScraper implements RecipeScraper {
  HttpRecipeScraper({
    http.Client? client,
    AiRecipeParser? aiParser,
    YouTubeRecipeParser? youtubeParser,
  })  : _client = client ?? http.Client(),
        _aiParser = aiParser,
        _youtubeParser = youtubeParser ??
            YouTubeRecipeParser(
              client: client,
            );

  final http.Client _client;
  final AiRecipeParser? _aiParser;
  final YouTubeRecipeParser _youtubeParser;

  static const String _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) '
      'Version/17.0 Mobile/15E148 Safari/604.1';

  @override
  Future<RecipeEntity> scrape(
    String url, {
    String languageCode = 'ru',
  }) async {
    final normalized = _normalizeUrl(url);

    if (YouTubeUrl.isYouTube(normalized)) {
      return _scrapeYouTube(
        normalized,
        languageCode: languageCode,
      );
    }

    return _scrapeHtml(
      normalized,
      languageCode: languageCode,
    );
  }

  Future<RecipeEntity> _scrapeYouTube(
    Uri uri, {
    required String languageCode,
  }) async {
    final result = await _youtubeParser.parse(
      uri,
      languageCode: languageCode,
    );

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
  }) async {
    final response = await _fetchHtml(uri);

    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw RecipeScrapeException(
        'HTTP ${response.statusCode} for $uri',
      );
    }

    final finalUrl =
        response.request?.url.toString() ?? uri.toString();

    final body = _decodeBody(response);
    final document = html_parser.parse(body);

    // 1. Schema.org JSON-LD.
    final jsonLd = _tryJsonLd(
      document,
      finalUrl,
    );

    if (jsonLd != null &&
        jsonLd.ingredients.isNotEmpty) {
      return jsonLd;
    }

    // 2. Microdata / HTML эвристики.
    final htmlRecipe = _fromHtmlHeuristics(
      document,
      finalUrl,
    );

    if (htmlRecipe.ingredients.length >= 2) {
      return htmlRecipe;
    }

    // 3. AI fallback.
    if (_aiParser != null) {
      final input = _buildAiInput(
        document,
        htmlRecipe,
      );

      if (input.readableText.isNotEmpty) {
        final aiRecipe = await _aiParser!.parse(
          pageText: input.toText(),
          sourceUrl: finalUrl,
          languageCode: languageCode,
        );

        if (aiRecipe != null &&
            aiRecipe.ingredients.isNotEmpty) {
          return aiRecipe;
        }
      }
    }

    // 4. Даже один найденный ингредиент лучше полного failure.
    if (htmlRecipe.ingredients.isNotEmpty) {
      return htmlRecipe;
    }

    throw const RecipeScrapeException(
      'Не удалось найти ингредиенты на странице.',
    );
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
        .timeout(
          const Duration(seconds: 20),
        );
  }

  String _decodeBody(http.Response response) {
    final contentType =
        response.headers['content-type'] ?? '';

    final charsetMatch = RegExp(
      r'charset=([^\s;]+)',
      caseSensitive: false,
    ).firstMatch(contentType);

    final charset =
        charsetMatch?.group(1)?.toLowerCase();

    final bytes = response.bodyBytes;

    if (charset == 'utf-8' ||
        charset == null ||
        charset == 'utf8') {
      return utf8.decode(
        bytes,
        allowMalformed: true,
      );
    }

    // dart:io doesn't provide arbitrary charset decoding.
    // UTF-8 fallback remains the safest client-only option.
    return utf8.decode(
      bytes,
      allowMalformed: true,
    );
  }

  Uri _normalizeUrl(String raw) {
    final value = raw.trim();

    if (value.isEmpty) {
      throw const RecipeScrapeException(
        'Пустой URL.',
      );
    }

    final normalized =
        value.startsWith('http://') ||
                value.startsWith('https://')
            ? value
            : 'https://$value';

    final uri = Uri.tryParse(normalized);

    if (uri == null ||
        uri.host.isEmpty) {
      throw const RecipeScrapeException(
        'Некорректный URL.',
      );
    }

    return uri;
  }

  // ---------------------------------------------------------------------------
  // JSON-LD
  // ---------------------------------------------------------------------------

  RecipeEntity? _tryJsonLd(
    dom.Document document,
    String sourceUrl,
  ) {
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

      final ingredients =
          _extractIngredients(
        recipe['recipeIngredient'],
      );

      if (ingredients.isEmpty) {
        continue;
      }

      return RecipeEntity(
        title:
            _asString(recipe['name']) ??
                _documentTitle(document),
        imageUrl:
            _extractImageUrl(
          recipe['image'],
        ) ??
                _metaContent(
                  document,
                  'og:image',
                ),
        servings:
            _asString(
              recipe['recipeYield'],
            ),
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
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');

    if (start >= 0 && end > start) {
      try {
        return jsonDecode(
          raw.substring(
            start,
            end + 1,
          ),
        );
      } catch (_) {}
    }

    return null;
  }


  Map<String, dynamic>? _findRecipeNode(
    dynamic node,
  ) {
    if (node is List) {
      for (final child in node) {
        final result =
            _findRecipeNode(child);

        if (result != null) {
          return result;
        }
      }

      return null;
    }

    if (node is Map) {
      final map = Map<String, dynamic>.from(
        node,
      );

      final type = map['@type'];

      final isRecipe =
          type == 'Recipe' ||
          (type is List &&
              type.contains('Recipe'));

      if (isRecipe) {
        return map;
      }

      final graph = map['@graph'];

      if (graph != null) {
        return _findRecipeNode(graph);
      }

      for (final value in map.values) {
        final nested =
            _findRecipeNode(value);

        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  List<RecipeIngredient> _extractIngredients(
    dynamic raw,
  ) {
    if (raw is! List) {
      return const [];
    }

    final result = <RecipeIngredient>[];

    for (final item in raw) {
      if (item is! String) {
        continue;
      }

      final text =
          _cleanText(item);

      if (text.isEmpty) {
        continue;
      }

      result.add(
        _parseIngredientLine(text),
      );
    }

    return _dedupeIngredients(result);
  }

  String? _extractImageUrl(
    dynamic raw,
  ) {
    if (raw is String) {
      return raw.trim();
    }

    if (raw is List &&
        raw.isNotEmpty) {
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

  
  RecipeEntity _fromHtmlHeuristics(
  dom.Document document,
  String sourceUrl,
) {
  final title = _documentTitle(document);

  final image = _metaContent(
    document,
    'og:image',
  );

  final ingredients = <RecipeIngredient>[];

  // 1. Сначала пробуем стандартные структуры.
  for (final element in document.querySelectorAll(
    '[itemprop="recipeIngredient"]',
  )) {
    _addIngredientIfValid(
      ingredients,
      element.text,
    );
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
      _addIngredientIfValid(
        ingredients,
        element.text,
      );
    }

    if (ingredients.length >= 2) {
      break;
    }
  }

  // 2. RussianFood.
  if (ingredients.length < 2) {
    final russianFoodIngredients =
        _parseRussianFoodIngredients(document);

    ingredients.addAll(
      russianFoodIngredients,
    );
  }

  return RecipeEntity(
    title: title,
    imageUrl: image,
    sourceUrl: sourceUrl,
    ingredients: _dedupeIngredients(
      ingredients,
    ),
  );
}
List<RecipeIngredient> _parseRussianFoodIngredients(
  dom.Document document,
) {
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
  ).firstMatch(
    normalized.substring(start),
  );

  final end = endMatch == null
      ? normalized.length
      : start + endMatch.start;

  final block = normalized.substring(
    start,
    end,
  );

  final lines = block
      .split('\n')
      .map(_cleanText)
      .where((line) => line.isNotEmpty)
      .toList();

  for (final line in lines) {
    final ingredient = _parseRussianFoodIngredient(
      line,
    );

    if (ingredient != null) {
      result.add(ingredient);
    }
  }

  return result;
}
RecipeIngredient? _parseRussianFoodIngredient(
  String raw,
) {
  final cleaned = _cleanText(
    raw
        .replaceAll('\u00A0', ' ')
        .trim(),
  );

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

  final name =
      match.namedGroup('name')!.trim();

  final quantity =
      match.namedGroup('quantity');

  final rawUnit =
      match.namedGroup('unit')?.trim();

  final note =
      match.namedGroup('note')?.trim();

  return RecipeIngredient(
    name: name,
    quantity: quantity,
    unit: _normalizeUnit(
      rawUnit,
    ),
    note: note,
    raw: raw,
  );
}

  void _addIngredientIfValid(
    List<RecipeIngredient> target,
    String raw,
  ) {
    final cleaned =
        _cleanText(raw);

    if (!_looksLikeIngredient(
      cleaned,
    )) {
      return;
    }

    target.add(
      _parseIngredientLine(cleaned),
    );
  }

  bool _looksLikeIngredient(
    String value,
  ) {
    if (value.length < 2 ||
        value.length > 300) {
      return false;
    }

    final lower =
        value.toLowerCase();

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

    return semanticMarkers.any(
      lower.contains,
    );
  }

  // ---------------------------------------------------------------------------
  // AI input
  // ---------------------------------------------------------------------------

  AiRecipeInput _buildAiInput(
    dom.Document document,
    RecipeEntity heuristicRecipe,
  ) {
    final clone =
        html_parser.parse(
      document.outerHtml,
    );

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

    for (final selector
        in dropSelectors) {
      for (final element
          in clone.querySelectorAll(
        selector,
      )) {
        element.remove();
      }
    }

    final root =
        clone.querySelector('article') ??
            clone.querySelector('main') ??
            clone.body ??
            clone.documentElement;

    final readableText =
        _cleanText(
      root?.text ?? '',
    );

    return AiRecipeInput(
      title: heuristicRecipe.title,
      candidateIngredients:
          heuristicRecipe.ingredients
              .map(
                (e) => e.raw,
              )
              .toList(),
      readableText: _limitText(
        readableText,
        maxCharacters: 40_000,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Ingredient normalization
  // ---------------------------------------------------------------------------

  static final RegExp _prefixQuantity =
      RegExp(
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

  static final RegExp _suffixQuantity =
      RegExp(
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

  RecipeIngredient _parseIngredientLine(
    String raw,
  ) {
    final cleaned =
        _cleanText(raw);

    final prefix =
        _prefixQuantity.firstMatch(
      cleaned,
    );

    if (prefix != null) {
      return RecipeIngredient(
        name:
            _cleanIngredientName(
          prefix.namedGroup(
            'name',
          ),
        ),
        quantity:
            prefix.namedGroup(
              'quantity',
            ),
        unit:
            _normalizeUnit(
          prefix.namedGroup(
            'unit',
          ),
        ),
        raw: raw,
      );
    }

    final suffix =
        _suffixQuantity.firstMatch(
      cleaned,
    );

    if (suffix != null) {
      return RecipeIngredient(
        name:
            _cleanIngredientName(
          suffix.namedGroup(
            'name',
          ),
        ),
        quantity:
            suffix.namedGroup(
              'quantity',
            ),
        unit:
            _normalizeUnit(
          suffix.namedGroup(
            'unit',
          ),
        ),
        raw: raw,
      );
    }

    return RecipeIngredient(
      name:
          _cleanIngredientName(
        cleaned,
      ),
      raw: raw,
    );
  }

  String _cleanIngredientName(
    String? value,
  ) {
    if (value == null) {
      return '';
    }

    var result = value.trim();

    result = result.replaceFirst(
      RegExp(
        r'^(?:of|из|для)\s+',
        caseSensitive: false,
      ),
      '',
    );

    return result;
  }

  String? _normalizeUnit(
  String? raw,
) {
  if (raw == null) {
    return null;
  }

  var value = raw
      .trim()
      .toLowerCase();

  value = value
      .replaceAll('.', '')
      .replaceAll(RegExp(r'\s+'), ' ');

  if (value.contains('кг')) return 'kg';
  if (value == 'г' || value.contains('грамм')) {
    return 'g';
  }

  if (value.contains('мл')) return 'ml';
  if (value == 'л' || value.contains('литр')) {
    return 'l';
  }

  if (value.contains('ст л') ||
      value.contains('ст лож')) {
    return 'tbsp';
  }

  if (value.contains('ч л') ||
      value.contains('ч лож')) {
    return 'tsp';
  }

  if (value.contains('шт') ||
      value.contains('штук')) {
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

  return null;
}

  List<RecipeIngredient> _dedupeIngredients(
    Iterable<RecipeIngredient> items,
  ) {
    final result =
        <RecipeIngredient>[];
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

  String _documentTitle(
    dom.Document document,
  ) {
    return _metaContent(
          document,
          'og:title',
        ) ??
        document
            .querySelector('h1')
            ?.text
            .trim() ??
        document
            .querySelector('title')
            ?.text
            .trim() ??
        'Рецепт';
  }

  String? _metaContent(
    dom.Document document,
    String property,
  ) {
    final element =
        document.querySelector(
              'meta[property="$property"]',
            ) ??
            document.querySelector(
              'meta[name="$property"]',
            );

    return element
        ?.attributes['content']
        ?.trim();
  }

  String _cleanText(
    String value,
  ) {
    return value
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  String _limitText(
    String value, {
    required int maxCharacters,
  }) {
    if (value.length <= maxCharacters) {
      return value;
    }

    return value.substring(
      0,
      maxCharacters,
    );
  }

  String? _asString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final trimmed =
          value.trim();

      return trimmed.isEmpty
          ? null
          : trimmed;
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
    final buffer =
        StringBuffer();

    if (title != null &&
        title!.isNotEmpty) {
      buffer.writeln(
        'TITLE:\n$title',
      );
    }

    if (candidateIngredients
        .isNotEmpty) {
      buffer.writeln(
        '\nCANDIDATE INGREDIENTS:',
      );

      for (final ingredient
          in candidateIngredients) {
        buffer.writeln(
          '- $ingredient',
        );
      }
    }

    buffer.writeln(
      '\nPAGE TEXT:\n$readableText',
    );

    return buffer.toString();
  }
}

class RecipeScrapeException
    implements Exception {
  final String message;

  const RecipeScrapeException(
    this.message,
  );

  @override
  String toString() =>
      'RecipeScrapeException: $message';
}