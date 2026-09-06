import 'dart:convert';

import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

/// Извлекает `<recipe>{...}</recipe>` JSON блок из сырого текста
/// assistant-сообщения. Возвращает [ChatRecipeExtraction] с чистым
/// текстом (без блока) и опциональным [RecipeEntity].
class ChatRecipeExtraction {
  const ChatRecipeExtraction({required this.cleanText, this.recipe});
  final String cleanText;
  final RecipeEntity? recipe;

  bool get hasRecipe => recipe != null;
}

class ChatRecipeExtractor {
  const ChatRecipeExtractor._();

  static final _tag = RegExp(
    r'<recipe>([\s\S]*?)</recipe>',
    caseSensitive: false,
  );

  static ChatRecipeExtraction extract(String raw) {
    final match = _tag.firstMatch(raw);
    final start = raw.toLowerCase().indexOf('<recipe>');
    if (match == null && start < 0) {
      return ChatRecipeExtraction(cleanText: raw.trim());
    }
    final jsonRaw = _stripCodeFence(
      match?.group(1)?.trim() ??
          raw.substring(start + '<recipe>'.length).trim(),
    );
    final cleanText = match == null
        ? raw.substring(0, start).trim()
        : raw.replaceAll(_tag, '').trim();

    if (jsonRaw.isEmpty) {
      return ChatRecipeExtraction(cleanText: cleanText);
    }
    try {
      final decoded = jsonDecode(jsonRaw);
      if (decoded is! Map) {
        return ChatRecipeExtraction(cleanText: cleanText);
      }
      final json = Map<String, dynamic>.from(decoded);
      final title = (json['title'] as String?)?.trim();
      if (title == null || title.isEmpty) {
        return ChatRecipeExtraction(cleanText: cleanText);
      }
      final servings = (json['servings'] as String?)?.trim();
      final rawIngs = (json['ingredients'] as List?) ?? const [];
      final ings = <RecipeIngredient>[];
      for (final r in rawIngs) {
        if (r is! Map<String, dynamic>) continue;
        final name = (r['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final qty = (r['quantity'] as String?)?.trim();
        final unit = (r['unit'] as String?)?.trim();
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
      if (ings.isEmpty) return ChatRecipeExtraction(cleanText: cleanText);
      return ChatRecipeExtraction(
        cleanText: cleanText,
        recipe: RecipeEntity(
          title: title,
          sourceUrl: 'ai://chat',
          servings: servings == null || servings.isEmpty ? null : servings,
          ingredients: ings,
        ),
      );
    } catch (_) {
      return ChatRecipeExtraction(cleanText: cleanText);
    }
  }

  static String _stripCodeFence(String value) {
    return value
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
  }
}
