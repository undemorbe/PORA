import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:pora/core/features/recipe/data/datasource/ai_recipe_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

/// Скачивает страницу и достаёт рецепт.
///
/// Стратегия:
///   1. JSON-LD `@type == 'Recipe'` (schema.org) — 90% сайтов.
///   2. HTML-эвристики: контейнеры с `ingredient` в class/id + микроформатные
///      атрибуты + `<article>` парсинг.
///   3. AI-fallback ([AiRecipeParser]) — очищаем страницу, шлём модели.
///
/// AI шаг только парсит присланный контент — не «сочиняет» рецепт.
abstract class RecipeScraper {
  Future<RecipeEntity> scrape(String url, {String languageCode = 'ru'});
}

class HttpRecipeScraper implements RecipeScraper {
  HttpRecipeScraper({
    http.Client? client,
    this.aiParser,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  /// Опциональный fallback — если null, AI-парсинг пропускается.
  final AiRecipeParser? aiParser;

  static const _ua =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
      'Mobile/15E148 Safari/604.1 (compatible; PoraBot/1.0)';

  @override
  Future<RecipeEntity> scrape(String url, {String languageCode = 'ru'}) async {
    final uri = _normalizeUrl(url);
    final response = await _fetchWithRedirects(uri);

    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw RecipeScrapeException('HTTP ${response.statusCode} for $uri');
    }

    final body = _decodeBody(response);
    final document = html_parser.parse(body);
    final finalUrl = response.request?.url.toString() ?? uri.toString();

    // 1. JSON-LD.
    final jsonLd = _tryJsonLd(document, finalUrl);
    if (jsonLd != null && jsonLd.ingredients.isNotEmpty) return jsonLd;

    // 2. HTML эвристики.
    final heur = _fromHtmlHeuristics(document, finalUrl);
    if (heur.ingredients.length >= 2) return heur;

    // 3. AI-парсинг очищенного текста.
    if (aiParser != null) {
      final text = _extractReadableText(document);
      final aiRecipe = await aiParser!.parse(
        pageText: text,
        sourceUrl: finalUrl,
        languageCode: languageCode,
      );
      if (aiRecipe != null && aiRecipe.ingredients.isNotEmpty) {
        return aiRecipe;
      }
    }

    // Если даже эвристики что-то нашли — вернём (пусть 1 элемент).
    if (heur.ingredients.isNotEmpty) return heur;

    throw const RecipeScrapeException(
      'Не удалось найти ингредиенты на странице',
    );
  }

  Uri _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    final withScheme =
        trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
    return Uri.parse(withScheme);
  }

  Future<http.Response> _fetchWithRedirects(Uri uri) async {
    // http.Client уже follows redirects по умолчанию, но некоторые сайты
    // отдают 403 без правильных заголовков. Даём Accept, Accept-Language,
    // Accept-Encoding.
    return _client
        .get(
          uri,
          headers: {
            'User-Agent': _ua,
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'ru,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate',
          },
        )
        .timeout(const Duration(seconds: 20));
  }

  String _decodeBody(http.Response r) {
    try {
      return utf8.decode(r.bodyBytes);
    } catch (_) {
      return r.body;
    }
  }

  // ---------- JSON-LD ----------

  RecipeEntity? _tryJsonLd(dom.Document doc, String sourceUrl) {
    final scripts = doc.querySelectorAll('script[type="application/ld+json"]');
    for (final s in scripts) {
      final raw = s.text;
      if (raw.trim().isEmpty) continue;
      dynamic decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        continue;
      }
      final recipeNode = _findRecipeNode(decoded);
      if (recipeNode == null) continue;
      final ingredients = _extractIngredients(recipeNode['recipeIngredient']);
      if (ingredients.isEmpty) continue;
      return RecipeEntity(
        title: _asString(recipeNode['name']) ?? 'Рецепт',
        imageUrl: _extractImageUrl(recipeNode['image']),
        servings: _asString(recipeNode['recipeYield']),
        sourceUrl: sourceUrl,
        ingredients: ingredients,
      );
    }
    return null;
  }

  Map<String, dynamic>? _findRecipeNode(dynamic node) {
    if (node is List) {
      for (final e in node) {
        final found = _findRecipeNode(e);
        if (found != null) return found;
      }
      return null;
    }
    if (node is Map<String, dynamic>) {
      final type = node['@type'];
      final isRecipe =
          type == 'Recipe' || (type is List && type.contains('Recipe'));
      if (isRecipe) return node;

      final graph = node['@graph'];
      if (graph != null) {
        final found = _findRecipeNode(graph);
        if (found != null) return found;
      }
    }
    return null;
  }

  List<RecipeIngredient> _extractIngredients(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType()
        .map((e) => e.toString())
        .where((s) => s.trim().isNotEmpty)
        .map(_parseIngredientLine)
        .toList();
  }

  String? _extractImageUrl(dynamic raw) {
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return _extractImageUrl(raw.first);
    if (raw is Map<String, dynamic>) return _asString(raw['url']);
    return null;
  }

  // ---------- HTML fallback ----------

  RecipeEntity _fromHtmlHeuristics(dom.Document doc, String sourceUrl) {
    final title = _metaContent(doc, 'og:title') ??
        doc.querySelector('title')?.text.trim() ??
        'Рецепт';
    final image = _metaContent(doc, 'og:image');

    // Ищем контейнеры по class/id + hrecipe / itemprop=recipeIngredient.
    final items = <RecipeIngredient>[];

    // 1) Microformat / microdata.
    for (final el
        in doc.querySelectorAll('[itemprop="recipeIngredient"], .ingredient')) {
      final text = el.text.trim();
      if (text.isEmpty) continue;
      items.add(_parseIngredientLine(text));
    }
    if (items.length >= 2) {
      return RecipeEntity(
        title: title,
        imageUrl: image,
        sourceUrl: sourceUrl,
        ingredients: items,
      );
    }

    // 2) Контейнеры с "ingredient" в class/id → все `<li>` внутри.
    final containers = <dom.Element>[];
    for (final el in doc.querySelectorAll('*')) {
      final cls = (el.attributes['class'] ?? '').toLowerCase();
      final id = (el.attributes['id'] ?? '').toLowerCase();
      if (cls.contains('ingredient') || id.contains('ingredient')) {
        containers.add(el);
      }
    }
    for (final c in containers) {
      final lis = c.querySelectorAll('li');
      for (final li in lis) {
        final text = li.text.trim();
        if (text.isEmpty) continue;
        items.add(_parseIngredientLine(text));
      }
      if (items.length >= 2) break;
    }

    return RecipeEntity(
      title: title,
      imageUrl: image,
      sourceUrl: sourceUrl,
      ingredients: items,
    );
  }

  String? _metaContent(dom.Document doc, String property) {
    final el = doc.querySelector('meta[property="$property"]') ??
        doc.querySelector('meta[name="$property"]');
    return el?.attributes['content']?.trim();
  }

  // ---------- Readable text for AI ----------

  /// Выкидывает script/style/nav/footer/aside — остаётся читаемый контент.
  /// Схлопывает пробелы. Ограничитель размера — на стороне AI-парсера.
  String _extractReadableText(dom.Document doc) {
    // Убираем шум.
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
    ];
    for (final sel in dropSelectors) {
      for (final el in doc.querySelectorAll(sel)) {
        el.remove();
      }
    }
    // Приоритет: <article> > <main> > <body>.
    final root = doc.querySelector('article') ??
        doc.querySelector('main') ??
        doc.body ??
        doc.documentElement!;
    final text = root.text;
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // ---------- Ingredient line parsing ----------

  /// "400 г спагетти" → {quantity: '400', unit: 'г', name: 'спагетти'}.
  static final _qtyUnitPattern = RegExp(
    r'^\s*(\d+[.,]?\d*(?:[-–—]\d+[.,]?\d*)?)\s*'
    r'([а-яa-z]+\.?)?\s+(.+)$',
    caseSensitive: false,
    unicode: true,
  );

  RecipeIngredient _parseIngredientLine(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    final match = _qtyUnitPattern.firstMatch(cleaned);
    if (match == null) {
      return RecipeIngredient(name: cleaned, raw: raw);
    }
    final qty = match.group(1);
    final unit = match.group(2);
    final rest = match.group(3)?.trim() ?? cleaned;
    return RecipeIngredient(
      name: rest,
      quantity: qty,
      unit: _isKnownUnit(unit) ? unit : null,
      raw: raw,
    );
  }

  bool _isKnownUnit(String? u) {
    if (u == null) return false;
    const units = {
      'г', 'кг', 'мг', 'мл', 'л', 'шт', 'ч', 'ст',
      'ложка', 'ложек', 'стакан', 'стаканов',
      'g', 'kg', 'ml', 'l', 'oz', 'lb', 'cup', 'cups', 'tsp', 'tbsp',
    };
    return units.contains(u.toLowerCase().replaceAll('.', ''));
  }

  String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.trim().isEmpty ? null : v.trim();
    return v.toString();
  }
}

class RecipeScrapeException implements Exception {
  final String message;
  const RecipeScrapeException(this.message);
  @override
  String toString() => 'RecipeScrapeException: $message';
}
