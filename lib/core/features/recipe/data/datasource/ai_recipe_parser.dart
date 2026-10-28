import 'dart:convert';

import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/data/datasource/ingredient_line_parser.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/recipe_units.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';

/// Normalizes raw page evidence into the recipe contract.
class AiRecipeParser {
  const AiRecipeParser({required this.ai});
  final AiRepository ai;

  Future<RecipeEntity?> parse({
    required String pageText,
    required String sourceUrl,
    required String languageCode,
  }) async {
    // Ограничиваем размер — большие статьи забивают контекст модели.
    // ~12k символов ≈ 3-4k токенов для многих моделей, безопасный лимит.
    final trimmed = pageText.length > 12000
        ? pageText.substring(0, 12000)
        : pageText;

    final systemPrompt =
        '''You are a recipe data normalizer.
  The user message contains a web page and candidate ingredients extracted from its markup.
  Return NO_RECIPE if the page is not a single cooking recipe.
  Otherwise return ONLY valid JSON, with no markdown or commentary:
  {"title":"string","servings":"string or null","foodEmoji":"one food emoji","ingredients":[{"name":"string","quantity":"string or null","unit":"string or null","note":"string or null"}]}
  Rules:
  - Use only ingredients explicitly supported by the page. Never invent or infer missing ingredients.
  - Remove navigation, ads, nutrition facts, preparation actions, headings, duplicate items and section labels
    ("For the sauce", "Для теста" are labels, not ingredients).
  - Put preparation details ("finely chopped", "room temperature", "to taste") into "note", not into "name".
  - If the same ingredient appears in several sections, keep each occurrence only when quantities differ.
  - Reconcile candidate markup with the page text; fix broken names, quantities and units.
  - Keep alternatives and notes in the ingredient name only when they are part of the ingredient.
  - Translate ingredient names AND units to the user's language ($languageCode).
  - Every ingredient name MUST start with an uppercase letter.
  - Never put a quantity or unit in title or ingredient name; keep them in dedicated JSON fields.
  - Never treat timestamps (0:00, 01:23), chapter labels, introductions, instructions, or cooking steps as ingredients.
  - For Russian use units such as г, кг, мл, л, шт, ст. л., ч. л.; for English use g, kg, ml, l, pcs, tbsp, tsp.
  - Preserve fractional quantities and ranges as strings.
  - Use canonical units when possible: g, kg, mg, ml, l, pcs, tbsp, tsp, cup, oz, lb, clove, can, bunch.
  - Choose exactly one relevant food emoji for the dish (for example 🍝, 🍲, 🥗, 🍰, 🍞, 🍎). Never return a generic face or symbol.
  ''';

    final watch = Stopwatch()..start();
    final res = await ai.chat(
      messages: [
        AiMessage.system(systemPrompt),
        AiMessage.user('SOURCE URL: $sourceUrl\n\nPAGE TEXT:\n$trimmed'),
      ],
      maxTokens: 1200,
      temperature: 0.1,
    );
    AnalyticsService.instance.logAiResponse(
      kind: 'recipe',
      success: res.isRight,
      latencyMs: watch.elapsedMilliseconds,
      error: res.isLeft ? res.left.runtimeType.toString() : null,
    );
    if (res.isLeft) return null;

    final raw = res.right.content.trim();
    if (raw.startsWith('NO_RECIPE') || raw.isEmpty) return null;

    return _parseJson(raw, sourceUrl, languageCode);
  }

  RecipeEntity? _parseJson(String raw, String sourceUrl, String languageCode) {
    var s = raw.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      s = s.replaceFirst(RegExp(r'\s*```\s*$'), '');
    }
    final objectStart = s.indexOf('{');
    final objectEnd = s.lastIndexOf('}');
    if (objectStart >= 0 && objectEnd > objectStart) {
      s = s.substring(objectStart, objectEnd + 1);
    }
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map) return null;
      final json = Map<String, dynamic>.from(decoded);
      // Без заголовка рецепт всё ещё полезен — скрейпер подставит title
      // со страницы.
      final title = _stringValue(json['title']) ?? '';
      final foodEmoji = _foodEmoji(_stringValue(json['foodEmoji']));
      final rawList = json['ingredients'];
      final raws = rawList is List ? rawList : const [];
      final ings = <RecipeIngredient>[];
      for (final r in raws) {
        final ingredient = _ingredient(r, languageCode);
        if (ingredient != null) ings.add(ingredient);
      }
      if (ings.isEmpty) return null;
      final servings = _stringValue(json['servings']);
      return RecipeEntity(
        title: title,
        sourceUrl: sourceUrl,
        foodEmoji: foodEmoji,
        servings: servings == null || servings.isEmpty ? null : servings,
        ingredients: ings,
      );
    } catch (_) {
      return null;
    }
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty || result.toLowerCase() == 'null' ? null : result;
  }

  String _capitalizeFirst(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    final first = String.fromCharCode(trimmed.runes.first);
    return '${first.toUpperCase()}${trimmed.substring(first.length)}';
  }

  String _cleanIngredientName(String value) {
    return value
        .replaceFirst(RegExp(r'^\s*\d{1,2}:\d{2}(?::\d{2})?\s*[-–—|:]?\s*'), '')
        .trim();
  }

  bool _isNonIngredientName(String value) {
    return RegExp(
      r'^\s*\d{1,2}:\d{2}(?::\d{2})?\b|\b(?:intro|introduction|вступление|instructions?|приготовление|шаг)\b',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(value);
  }

  /// Элемент `ingredients`: объект `{name, quantity, unit, note}` или
  /// строка «200 г муки». Количество, «утёкшее» в name, вынимается
  /// общим [IngredientLineParser].
  RecipeIngredient? _ingredient(dynamic value, String languageCode) {
    if (value is String) {
      if (_isNonIngredientName(value)) return null;
      final parsed = IngredientLineParser.parse(value);
      return _build(
        name: parsed.name,
        quantity: parsed.quantity,
        unit: parsed.unit,
        note: parsed.note,
        languageCode: languageCode,
      );
    }
    if (value is! Map) return null;
    final rawName = _stringValue(value['name']) ?? '';
    if (rawName.isEmpty || _isNonIngredientName(rawName)) return null;
    var name = _cleanIngredientName(rawName);
    var quantity = _stringValue(value['quantity']);
    var unit = _stringValue(value['unit']);
    var note = _stringValue(value['note']);
    if (quantity == null && RegExp(r'\d').hasMatch(name)) {
      final embedded = IngredientLineParser.parse(name);
      if (embedded.quantity != null) {
        name = embedded.name;
        quantity = embedded.quantity;
        unit ??= embedded.unit;
        note ??= embedded.note;
      }
    }
    return _build(
      name: name,
      quantity: quantity,
      unit: unit,
      note: note,
      languageCode: languageCode,
    );
  }

  RecipeIngredient? _build({
    required String name,
    required String? quantity,
    required String? unit,
    required String? note,
    required String languageCode,
  }) {
    final cleanName = _capitalizeFirst(name);
    if (cleanName.isEmpty) return null;
    final localizedUnit = RecipeUnits.localize(unit, languageCode);
    return RecipeIngredient(
      name: cleanName,
      quantity: quantity,
      unit: localizedUnit,
      note: note,
      raw: [
        quantity,
        localizedUnit,
        cleanName,
      ].where((e) => e != null && e.isNotEmpty).join(' '),
    );
  }

  String? _foodEmoji(String? value) {
    if (value == null) return null;
    const allowed = {
      '🍝',
      '🍲',
      '🥗',
      '🍰',
      '🍞',
      '🍎',
      '🍕',
      '🍔',
      '🌮',
      '🍜',
      '🍛',
      '🥪',
      '🥞',
      '🧁',
      '🍪',
      '🍗',
      '🥩',
      '🐟',
      '🍳',
      '🥣',
      '🍚',
      '🥟',
      '🌯',
      '🥘',
      '🍨',
      '🍓',
      '🥦',
      '🥕',
      '🧀',
      '🍅',
      '🥒',
      '🌽',
      '🍋',
    };
    return allowed.contains(value.trim()) ? value.trim() : null;
  }
}
