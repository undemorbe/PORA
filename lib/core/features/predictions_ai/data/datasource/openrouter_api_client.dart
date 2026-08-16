import 'package:dio/dio.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_completion_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'openrouter_api_client.g.dart';

/// Retrofit-контракт OpenRouter. Отдельный от общего `ApiClient` — свой
/// baseUrl, свой Bearer-key (из dotenv), никакого auth interceptor'а от
/// приложения.
@RestApi()
abstract class OpenRouterApiClient {
  factory OpenRouterApiClient(Dio dio, {String? baseUrl}) =
      _OpenRouterApiClient;

  /// POST `<base>/chat/completions`.
  /// Тело — уже собранный jsonable-Map (model/messages/temperature/max_tokens).
  /// Ответ парсится в [AiCompletionModel] через его `fromJson`.
  @POST('chat/completions')
  Future<AiCompletionModel> chatCompletions(
    @Body() Map<String, dynamic> body,
  );
}
