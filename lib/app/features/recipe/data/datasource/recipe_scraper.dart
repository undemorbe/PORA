import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:pora/app/features/recipe/domain/entity/recipe.dart';
import 'package:pora/app/features/recipe/domain/entity/recipe_ingredient.dart';

/// Скачивает страницу и достаёт рецепт.
///
/// Стратегия:
///   1. `<script type="application/ld+json">` — ищем объект с `@type == "Recipe"`
///      (schema.org). Даёт structured `recipeIngredient`, `name`, `image`,
///      `recipeYield` — 90% сайтов еды.
///   2. Fallback: OpenGraph `og:title` + первый `<img>` + любые `<li>` из
///      блоков с классом/id, содержащим `ingredient`.
abstract class RecipeScraper {
  Future<RecipeEntity> scrape(String url);
}

class HttpRecipeScraper implements RecipeScraper {
  HttpRecipeScraper({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _ua =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
      'Mobile/15E148 Safari/604.1 (compatible; PoraBot/1.0)';

  @override
  Future<RecipeEntity> scrape(String url) async {
    final uri = _normalizeUrl(url);
    final response = await _client
        .get(uri, headers: {'User-Agent': _ua, 'Accept-Language': 'ru,en'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw RecipeScrapeException('HTTP ${response.statusCode} for $uri');
    }

    // Кодировку HTTP-заголовок не всегда даёт правильно — берём bodyBytes+utf8.
    final body = _decodeBody(response);
    final document = html_parser.parse(body);

    final jsonLd = _tryJsonLd(document, uri.toString());
    if (jsonLd != null && jsonLd.ingredients.isNotEmpty) return jsonLd;

    final fallback = _fromHtmlHeuristics(document, uri.toString());
    if (fallback.ingredients.isEmpty) {
      throw const RecipeScrapeException(
        'Не удалось найти ингредиенты на странице',
      );
    }
    return fallback;
  }

  Uri _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    final withScheme = trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
    return Uri.parse(withScheme);
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

  /// Обходит структуру JSON-LD (может быть object / array / @graph)
  /// и находит первый узел с `@type == 'Recipe'`.
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
      final isRecipe = type == 'Recipe' ||
          (type is List && type.contains('Recipe'));
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

    // Ищем контейнеры с "ingredient" в class/id. package:html не
    // поддерживает `[attr*="v" i]` — обходим все узлы вручную.
    final candidates = <dom.Element>[];
    for (final el in doc.querySelectorAll('*')) {
      final cls = (el.attributes['class'] ?? '').toLowerCase();
      final id = (el.attributes['id'] ?? '').toLowerCase();
      if (cls.contains('ingredient') || id.contains('ingredient')) {
        candidates.add(el);
      }
    }

    final items = <RecipeIngredient>[];
    for (final c in candidates) {
      final lis = c.querySelectorAll('li');
      for (final li in lis) {
        final text = li.text.trim();
        if (text.isEmpty) continue;
        items.add(_parseIngredientLine(text));
      }
      if (items.isNotEmpty) break;
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

  // ---------- Ingredient line parsing ----------

  /// "400 г спагетти" → {quantity: '400', unit: 'г', name: 'спагетти'}.
  /// "2 шт яйца" / "Чёрный перец по вкусу" — best-effort.
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
      'г', 'кг', 'мг',
      'мл', 'л',
      'шт', 'ч', 'ст', 'ложка', 'ложек', 'стакан', 'стаканов',
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
