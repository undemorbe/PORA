import 'package:pora/core/features/predictions_ai/data/models/ai_completion_model.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_message_model.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

/// Абстракция сетевого слоя AI. Реализация — `AiRemoteImpl` (OpenRouter).
abstract class AiRemote {
  Future<Either<Failure, AiCompletionModel>> chat({
    required List<AiMessageModel> messages,
    required int maxTokens,
    required double temperature,
  });

  /// Освободить http-клиент. Вызывается при shutdown DI.
  void dispose();
}
