import 'dart:convert';

import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

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
  {"title":"string","servings":"string or null","foodEmoji":"one food emoji","ingredients":[{"name":"string","quantity":"string or null","unit":"string or null"}]}
  Rules:
  - Use only ingredients explicitly supported by the page. Never invent or infer missing ingredients.
  - Remove navigation, ads, nutrition facts, preparation actions, headings, duplicate items and section labels.
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

    final res = await ai.chat(
      messages: [
        AiMessage.system(systemPrompt),
        AiMessage.user('SOURCE URL: $sourceUrl\n\nPAGE TEXT:\n$trimmed'),
      ],
      maxTokens: 1200,
      temperature: 0.1,
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
      final title = _stringValue(json['title']);
      if (title == null || title.isEmpty) return null;
      final foodEmoji = _foodEmoji(_stringValue(json['foodEmoji']));
      final raws = (json['ingredients'] as List?) ?? const [];
      final ings = <RecipeIngredient>[];
      for (final r in raws) {
        if (r is! Map) continue;
        final item = Map<String, dynamic>.from(r);
        final embedded = _extractEmbeddedAmount(
          _stringValue(item['name']) ?? '',
          languageCode,
        );
        final cleanedName = _cleanIngredientName(embedded.name);
        if (_isNonIngredientName(_stringValue(item['name']) ?? cleanedName)) {
          continue;
        }
        final name = _capitalizeFirst(cleanedName);
        if (name.isEmpty) continue;
        final qty = _stringValue(item['quantity']) ?? embedded.quantity;
        final unit = _normalizeUnit(
          _stringValue(item['unit']) ?? embedded.unit,
          languageCode,
        );
        final joined = [
          qty,
          unit,
          name,
        ].where((e) => e != null && e.isNotEmpty).join(' ');
        ings.add(
          RecipeIngredient(
            name: name,
            quantity: qty == null || qty.isEmpty ? null : qty,
            unit: unit == null || unit.isEmpty ? null : unit,
            raw: joined,
          ),
        );
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

  ({String name, String? quantity, String? unit}) _extractEmbeddedAmount(
    String value,
    String languageCode,
  ) {
    const unitPattern =
        r'(?:грамм(?:а|ов)?|г|кг|мг|мл|л|шт\.?|штук|'
        r'ст\.?\s*л\.?|столов(?:ая|ой)\s+ложк(?:а|и)|'
        r'ч\.?\s*л\.?|чайная\s+ложк(?:а|и)|'
        r'g|grams?|kg|mg|ml|l|pcs?|tsp|tbsp|tablespoons?|cup|cups|oz|lb)';
    final prefix = RegExp(
      r'^\s*(?<quantity>\d+(?:[.,]\d+)?)\s*'
      '(?<unit>$unitPattern)\\s+'
      r'(?<name>.+?)\s*$',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(value);
    if (prefix != null) {
      return (
        name: prefix.namedGroup('name')!.trim(),
        quantity: prefix.namedGroup('quantity'),
        unit: _normalizeUnit(prefix.namedGroup('unit'), languageCode),
      );
    }

    final suffix = RegExp(
      [
        r'^\s*(?<name>.+?)\s*(?:[-–—,:]|[(])\s*',
        r'(?<quantity>\d+(?:[.,]\d+)?)\s*',
        '(?<unit>$unitPattern)',
        r'\)?\s*$',
      ].join(),
      caseSensitive: false,
      unicode: true,
    ).firstMatch(value);
    final looseSuffix =
        suffix ??
        RegExp(
          [
            r'^\s*(?<name>.+?)\s+',
            r'(?<quantity>\d+(?:[.,]\d+)?)\s*',
            '(?<unit>$unitPattern)',
            r'\s*$',
          ].join(),
          caseSensitive: false,
          unicode: true,
        ).firstMatch(value);
    if (looseSuffix == null) {
      return (name: value.trim(), quantity: null, unit: null);
    }
    return (
      name: looseSuffix.namedGroup('name')!.trim(),
      quantity: looseSuffix.namedGroup('quantity'),
      unit: _normalizeUnit(looseSuffix.namedGroup('unit'), languageCode),
    );
  }

  String? _normalizeUnit(String? value, String languageCode) {
    if (value == null) return null;
    final normalized = value.toLowerCase().replaceAll('.', '').trim();
    const aliases = {
      'г': 'g',
      'гр': 'g',
      'грамм': 'g',
      'грамма': 'g',
      'граммов': 'g',
      'кг': 'kg',
      'мг': 'mg',
      'мл': 'ml',
      'л': 'l',
      'шт': 'pcs',
      'штук': 'pcs',
      'grams': 'g',
      'gram': 'g',
      'pcs': 'pcs',
      'tablespoon': 'tbsp',
      'tablespoons': 'tbsp',
      'teaspoon': 'tsp',
      'teaspoons': 'tsp',
      'ст л': 'tbsp',
      'столовая ложка': 'tbsp',
      'ч л': 'tsp',
      'чайная ложка': 'tsp',
      'стакан': 'cup',
      'зубчик': 'clove',
      'банка': 'can',
      'пучок': 'bunch',
    };
    final canonical = aliases[normalized] ?? normalized;
    if (!languageCode.toLowerCase().startsWith('ru')) return canonical;
    const russian = {
      'g': 'г',
      'kg': 'кг',
      'mg': 'мг',
      'ml': 'мл',
      'l': 'л',
      'pcs': 'шт',
      'tbsp': 'ст. л.',
      'tsp': 'ч. л.',
      'cup': 'стакан',
      'clove': 'зубчик',
      'can': 'банка',
      'bunch': 'пучок',
    };
    return russian[canonical] ?? canonical;
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
