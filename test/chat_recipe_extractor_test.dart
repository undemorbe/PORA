import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_completion_model.dart';
import 'package:pora/core/features/recipe/domain/chat_recipe_extractor.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/chat_message_bubble.dart';

void main() {
  test('extracts a fenced recipe block', () {
    final result = ChatRecipeExtractor.extract(
      'Dinner\n<recipe>```json\n{"title":"Rice","ingredients":[{"name":"rice","quantity":"1","unit":"cup"}]}\n```</recipe>',
    );

    expect(result.recipe?.title, 'Rice');
    expect(result.recipe?.ingredients.single.name, 'rice');
    expect(result.cleanText, 'Dinner');
  });

  test('extracts complete JSON without a closing tag', () {
    final result = ChatRecipeExtractor.extract(
      'Recipe:\n<recipe>{"title":"Soup","ingredients":[{"name":"water"}]}',
    );

    expect(result.recipe?.title, 'Soup');
    expect(result.recipe?.ingredients.single.name, 'water');
    expect(result.cleanText, 'Recipe:');
  });

  test('converts markdown tables to mobile-safe lists', () {
    final result = normalizeChatMarkdown(
      'Plan:\n| Product | Amount |\n| --- | --- |\n| Rice | 1 cup |',
    );

    expect(result, contains('- **Product:** Rice'));
    expect(result, contains('- **Amount:** 1 cup'));
    expect(result, isNot(contains('| --- |')));
  });

  test('reports an OpenRouter provider error from an empty completion', () {
    expect(
      () => AiCompletionModel.fromJson({
        'choices': <Object>[],
        'error': {'message': 'No endpoints available'},
      }),
      throwsA(
        predicate<FormatException>(
          (error) => error.message.contains('No endpoints available'),
        ),
      ),
    );
  });
}
