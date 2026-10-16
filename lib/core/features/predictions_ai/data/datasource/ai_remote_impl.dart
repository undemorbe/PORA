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
  const AiRemoteImpl({
    required this.client,
    required this.modelResolver,
    this.maxRetries = 2,
    this.sleep = _delay,
  });

  final OpenRouterApiClient client;

  /// Повторы для временных сбоев провайдера (timeout, 5xx, короткий 429).
  final int maxRetries;

  /// Подменяется в тестах, чтобы не ждать реальный backoff.
  final Future<void> Function(Duration) sleep;

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
    final body = {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
    for (var attempt = 0; ; attempt++) {
      try {
        final result = await client.chatCompletions(body);
        return Right(result);
      } catch (e, s) {
        final failure = FailureMapper.map(e, s);
        final wait = retryDelay(failure, attempt);
        if (attempt >= maxRetries || wait == null) {
          if (failure is RateLimitFailure) {
            Logger.talker.warning(
              'AI rate limit reached'
              '${failure.retryAfterSeconds == null ? '' : '; retry-after: ${failure.retryAfterSeconds}'}',
            );
          }
          return Left(failure);
        }
        Logger.talker.info(
          'AI request failed (${failure.runtimeType}), retry #${attempt + 1} '
          'in ${wait.inMilliseconds} ms',
        );
        await sleep(wait);
      }
    }
  }

  static Future<void> _delay(Duration d) => Future<void>.delayed(d);

  /// Пауза перед повтором или `null`, если ошибка не временная
  /// (неверный ключ, 4xx, офлайн — повтор не поможет).
  static Duration? retryDelay(Failure failure, int attempt) {
    final backoff = Duration(milliseconds: 700 * (1 << attempt));
    if (failure is RateLimitFailure) {
      final after = failure.retryAfterSeconds;
      if (after == null) return backoff * 2;
      // Долгий бан не ждём — пользователь смотрит на спиннер.
      return after <= 5 ? Duration(seconds: after) : null;
    }
    if (failure is TimeoutFailure) return backoff;
    if (failure is ApiFailure) {
      final status = failure.statusCode ?? 0;
      return status >= 500 && status < 600 ? backoff : null;
    }
    return null;
  }

  @override
  void dispose() {
    // Dio lifecycle managed by DI (singleton).
  }
}
