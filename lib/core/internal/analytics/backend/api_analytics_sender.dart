import 'package:dio/dio.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';

/// Отправка батча через `ApiClient.sendAnalyticsEvents`. [post] принимает
/// тело запроса — так sender тестируется без Dio/DI:
/// `apiAnalyticsSender((body) => api.sendAnalyticsEvents(body: body))`.
AnalyticsBatchSender apiAnalyticsSender(
  Future<void> Function(Map<String, dynamic> body) post,
) {
  return (events) async {
    try {
      await post({'events': events});
      return SendOutcome.sent;
    } catch (error) {
      return classifySendError(error);
    }
  };
}

/// 4xx (кроме 401/408/429) — данные не примут и при повторе → выбросить.
/// Остальное (сеть, таймаут, 5xx, протухший токен) — повторить позже.
SendOutcome classifySendError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null &&
        status >= 400 &&
        status < 500 &&
        status != 401 &&
        status != 408 &&
        status != 429) {
      return SendOutcome.drop;
    }
  }
  return SendOutcome.retry;
}
