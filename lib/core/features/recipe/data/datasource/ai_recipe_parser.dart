import 'dart:convert';

import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/ai_repository.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

/// Используется как fallback когда JSON-LD и HTML-эвристики не сработали.
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
        'You are a strict content extractor. You will receive raw text of a '
        'web page. If it contains a cooking recipe, extract structured data. '
        'If it does NOT contain a recipe, return exactly the string "NO_RECIPE".\n'
        'When a recipe is present, return ONLY valid minified JSON, no markdown, '
        'no commentary. Schema:\n'
        '{"title": string, "servings": string, '
        '"ingredients": [{"name": string, "quantity": string, "unit": string}]}\n'
        'All values MUST come from the source page — do NOT invent ingredients. '
        'All text fields — in language identified by ISO code "$languageCode" '
        '(translate the extracted names if needed, do not translate quantities/units).';

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

    return _parseJson(raw, sourceUrl);
  }

  RecipeEntity? _parseJson(String raw, String sourceUrl) {
    var s = raw.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      s = s.replaceFirst(RegExp(r'\s*```\s*$'), '');
    }
    try {
      final json = jsonDecode(s) as Map<String, dynamic>;
      final title = (json['title'] as String?)?.trim();
      if (title == null || title.isEmpty) return null;
      final raws = (json['ingredients'] as List?) ?? const [];
      final ings = <RecipeIngredient>[];
      for (final r in raws) {
        if (r is! Map<String, dynamic>) continue;
        final name = (r['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final qty = (r['quantity'] as String?)?.trim();
        final unit = (r['unit'] as String?)?.trim();
        final joined = [qty, unit, name]
            .where((e) => e != null && e.isNotEmpty)
            .join(' ');
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
      final servings = (json['servings'] as String?)?.trim();
      return RecipeEntity(
        title: title,
        sourceUrl: sourceUrl,
        servings: servings == null || servings.isEmpty ? null : servings,
        ingredients: ings,
      );
    } catch (_) {
      return null;
    }
  }
}
