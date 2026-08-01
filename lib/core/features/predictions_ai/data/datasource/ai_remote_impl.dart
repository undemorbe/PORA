import 'package:pora/core/features/predictions_ai/data/datasource/ai_remote.dart';
import 'package:pora/core/features/predictions_ai/data/datasource/openrouter_api_client.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_completion_model.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_message_model.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Реализация [AiRemote] поверх Retrofit/Dio (`OpenRouterApiClient`).
/// Model берётся из dotenv, key/baseUrl вешаются на Dio через DI.
/// Все исключения нормализует `FailureMapper` — единый Talker-логгинг.
class AiRemoteImpl implements AiRemote {
  const AiRemoteImpl({required this.client, required this.model});

  final OpenRouterApiClient client;

  /// Идентификатор модели (`AI_MODEL` из dotenv).
  final String model;

  @override
  Future<Either<Failure, AiCompletionModel>> chat({
    required List<AiMessageModel> messages,
    required int maxTokens,
    required double temperature,
  }) async {
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
      return Left(FailureMapper.map(e, s));
    }
  }

  @override
  void dispose() {
    // Dio lifecycle managed by DI (singleton).
  }
}
