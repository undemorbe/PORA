import 'package:flutter/foundation.dart' show ValueGetter;
import 'package:pora/core/features/predictions_ai/data/datasource/ai_remote.dart';
import 'package:pora/core/features/predictions_ai/data/datasource/openrouter_api_client.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_completion_model.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_message_model.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/logging/logger.dart';

class AiRemoteImpl implements AiRemote {
  const AiRemoteImpl({required this.client, required this.modelResolver});

  final OpenRouterApiClient client;

  /// Резолвер имени модели — вызывается на каждый запрос, чтобы подхватывать
  /// смену модели в настройках без пересоздания datasource/DI.
  final ValueGetter<String> modelResolver;

  @override
  Future<Either<Failure, AiCompletionModel>> chat({
    required List<AiMessageModel> messages,
    required int maxTokens,
    required double temperature,
  }) async {
    final model = modelResolver();
    if (model.isEmpty) {
      return Left(const ServerFailure('AI model is not configured'));
    }
    try {
      final result = await client.chatCompletions({
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': temperature,
        'max_tokens': maxTokens,
      });
      return Right(result);
    } catch (e, s) {
      final failure = FailureMapper.map(e, s);
      if (failure is RateLimitFailure) {
        Logger.talker.warning(
          'AI rate limit reached'
          '${failure.retryAfterSeconds == null ? '' : '; retry-after: ${failure.retryAfterSeconds}'}',
        );
      }
      return Left(failure);
    }
  }

  @override
  void dispose() {
    // Dio lifecycle managed by DI (singleton).
  }
}
