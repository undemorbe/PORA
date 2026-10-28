import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/predictions_ai/data/datasource/ai_remote_impl.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/chat_with_pora.dart';
import 'package:pora/core/features/recipe/domain/chat_recipe_extractor.dart';
import 'package:pora/core/internal/errors/api_error_code.dart';
import 'package:pora/core/internal/errors/failure.dart';

void main() {
  group('ChatWithPoraUseCase.compactHistory', () {
    test('strips <recipe> JSON from previous assistant answers', () {
      final out = ChatWithPoraUseCase.compactHistory([
        const AiMessage.user('Рецепт борща?'),
        const AiMessage.assistant(
          'Вот борщ.\n<recipe>{"title":"Борщ","ingredients":[]}</recipe>',
        ),
        const AiMessage.user('А без мяса?'),
      ]);
      expect(out[1].content, 'Вот борщ.');
      expect(out[0].content, 'Рецепт борща?');
    });

    test('window starts with a user message', () {
      final history = [
        for (var i = 0; i < 7; i++) ...[
          AiMessage.user('q$i'),
          AiMessage.assistant('a$i'),
        ],
      ];
      final out = ChatWithPoraUseCase.compactHistory(history);
      expect(out.length, lessThanOrEqualTo(ChatWithPoraUseCase.historyWindow));
      expect(out.first.role, 'user');
      expect(out.last.content, 'a6');
    });
  });

  group('AiRemoteImpl.retryDelay', () {
    test('retries transient errors only', () {
      expect(AiRemoteImpl.retryDelay(const TimeoutFailure(), 0), isNotNull);
      expect(
        AiRemoteImpl.retryDelay(
          const ApiFailure(
            code: ApiErrorCode.unknown,
            message: 'bad gateway',
            statusCode: 502,
          ),
          1,
        ),
        const Duration(milliseconds: 1400),
      );
      expect(
        AiRemoteImpl.retryDelay(
          const RateLimitFailure(message: 'slow down', retryAfterSeconds: 2),
          0,
        ),
        const Duration(seconds: 2),
      );
      // Долгий бан и клиентские ошибки — без повторов.
      expect(
        AiRemoteImpl.retryDelay(
          const RateLimitFailure(message: 'x', retryAfterSeconds: 60),
          0,
        ),
        isNull,
      );
      expect(
        AiRemoteImpl.retryDelay(
          const ApiFailure(
            code: ApiErrorCode.unknown,
            message: 'unauthorized',
            statusCode: 401,
          ),
          0,
        ),
        isNull,
      );
      expect(AiRemoteImpl.retryDelay(const NetworkFailure(), 0), isNull);
    });
  });

  group('ChatRecipeExtractor', () {
    test('accepts numeric quantity/servings from the model', () {
      final r = ChatRecipeExtractor.extract(
        'Текст\n<recipe>{"title":"Омлет","servings":2,'
        '"ingredients":[{"name":"Яйца","quantity":3,"unit":"шт"}]}</recipe>',
      );
      expect(r.cleanText, 'Текст');
      expect(r.recipe?.servings, '2');
      expect(r.recipe?.ingredients.single.quantity, '3');
    });
  });
}
