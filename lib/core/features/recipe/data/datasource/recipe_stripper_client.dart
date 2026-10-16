import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:pora/core/features/recipe/data/datasource/browser_profile.dart';
import 'package:pora/core/features/recipe/data/datasource/ingredient_line_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/recipe_units.dart';

/// Внешний экстрактор recipestripper.com — серверный парсер, который
/// справляется с JS-сайтами и страницами, где у нас нет разметки.
///
/// Используется `POST /api/translate {url}` — тот же вызов, что делает их
/// веб-клиент (`/?url=` отдаёт только SPA-оболочку без рецепта). API
/// недокументирован, поэтому любой сбой → `null`, а не исключение.
class RecipeStripperClient {
  RecipeStripperClient({
    http.Client? client,
    String host = defaultHost,
    this.timeout = const Duration(seconds: 25),
  }) : _client = client ?? http.Client(),
       host = _sanitizeHost(host);

  static const defaultHost = 'recipestripper.com';

  final http.Client _client;
  final String host;
  final Duration timeout;

  static String _sanitizeHost(String raw) {
    final value = raw.trim().replaceFirst(RegExp(r'^https?://'), '');
    final hostOnly = value.split('/').first;
    return hostOnly.isEmpty ? defaultHost : hostOnly;
  }

  Future<RecipeEntity?> fetch(
    Uri source, {
    required BrowserProfile profile,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.https(host, '/api/translate'),
            headers: profile.apiHeaders(origin: 'https://$host'),
            body: jsonEncode({'url': source.toString()}),
          )
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      return parseResponse(
        jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true)),
        source.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Маппинг ответа `{success, recipe: {title, ingredients: [{raw, item,
  /// quantity?, unit?, preparation?}], servings, imageUrl}}`.
  @visibleForTesting
  static RecipeEntity? parseResponse(dynamic decoded, String sourceUrl) {
    if (decoded is! Map || decoded['success'] != true) return null;
    final recipe = decoded['recipe'];
    if (recipe is! Map) return null;

    final ingredients = <RecipeIngredient>[];
    final raws = recipe['ingredients'];
    if (raws is List) {
      for (final item in raws) {
        final parsed = _ingredient(item);
        if (parsed != null) ingredients.add(parsed);
      }
    }
    if (ingredients.isEmpty) return null;

    final servings =
        _string(recipe['servingsText']) ?? _string(recipe['servings']);
    return RecipeEntity(
      title: _string(recipe['title']) ?? '',
      imageUrl: _string(recipe['imageUrl']),
      servings: servings,
      sourceUrl: _string(recipe['url']) ?? sourceUrl,
      ingredients: ingredients,
      extractor: 'recipestripper',
    );
  }

  static RecipeIngredient? _ingredient(dynamic item) {
    if (item is String) {
      return IngredientLineParser.looksLikeIngredient(item, strict: false)
          ? IngredientLineParser.parse(item)
          : null;
    }
    if (item is! Map) return null;
    final raw = _string(item['raw']) ?? _string(item['item']);
    if (raw == null) return null;
    final text = _string(item['item']) ?? raw;
    final preparation = _string(item['preparation']);
    final quantity = item['quantity'];

    RecipeIngredient result;
    if (quantity is num) {
      // API уже вынул количество — разбираем только название.
      final parsedName = IngredientLineParser.parse(text);
      final apiUnit = _string(item['unit']);
      result = RecipeIngredient(
        name: parsedName.name,
        quantity: _formatNumber(quantity),
        unit: RecipeUnits.canonical(apiUnit) ?? parsedName.unit ?? apiUnit,
        note: parsedName.note,
        raw: IngredientLineParser.clean(raw),
      );
    } else {
      // RU-сайты: количество остаётся в строке («Мука - 200 г»).
      result = IngredientLineParser.parse(raw);
    }
    if (preparation != null &&
        result.note != null &&
        !result.note!.contains(preparation)) {
      result = result.copyWith(note: '${result.note}; $preparation');
    } else if (preparation != null && result.note == null) {
      result = result.copyWith(note: preparation);
    }
    return result.name.trim().isEmpty ? null : result;
  }

  static String _formatNumber(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    const fractions = {'0.25': '1/4', '0.50': '1/2', '0.75': '3/4'};
    final whole = value.floor();
    final frac = fractions[(value - whole).toStringAsFixed(2)];
    if (frac != null) return whole == 0 ? frac : '$whole $frac';
    return double.parse(value.toStringAsFixed(2)).toString();
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty || s == 'null' ? null : s;
  }
}
