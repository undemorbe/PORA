import 'package:dio/dio.dart';
import 'package:pora/core/features/predictions_ai/data/models/ai_completion_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'openrouter_api_client.g.dart';

@RestApi()
abstract class OpenRouterApiClient {
  factory OpenRouterApiClient(Dio dio, {String? baseUrl}) =
      _OpenRouterApiClient;

  @POST('chat/completions')
  Future<AiCompletionModel> chatCompletions(@Body() Map<String, dynamic> body);
}
