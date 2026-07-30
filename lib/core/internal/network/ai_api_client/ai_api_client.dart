// import 'package:dio/dio.dart';
// import 'package:pora/core/features/predictions_ai/data/models/tip_model.dart';
// import 'package:retrofit/http.dart';

// part 'ai_api_client.g.dart';

// /// Единый HTTP-контракт (Retrofit). Возвращает DTO/void — без Either/Failure
// /// (перевод ошибок в репозиториях). Authorization подставляет AuthInterceptor.
// @RestApi()
// abstract class AiApiClient {
//   factory AiApiClient(Dio dio, {String? baseUrl}) = _AiApiClient;

//   @GET('/chat/completions')
//   Future<Map<String, dynamic>> getCulinarTip({@Body(nullToAbsent: true) Map<String,dynamic>? body});

// }
