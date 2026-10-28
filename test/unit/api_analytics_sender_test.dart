import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/backend/api_analytics_sender.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';

DioException _http(int status) => DioException(
  requestOptions: RequestOptions(path: '/analytics/events'),
  response: Response(
    requestOptions: RequestOptions(path: '/analytics/events'),
    statusCode: status,
  ),
);

void main() {
  test('success → sent', () async {
    Map<String, dynamic>? sentBody;
    final send = apiAnalyticsSender((body) async => sentBody = body);

    final outcome = await send([
      {'id': '1'},
    ]);

    expect(outcome, SendOutcome.sent);
    expect(sentBody, {
      'events': [
        {'id': '1'},
      ],
    });
  });

  test('error classification', () {
    expect(classifySendError(_http(400)), SendOutcome.drop);
    expect(classifySendError(_http(413)), SendOutcome.drop);
    expect(classifySendError(_http(401)), SendOutcome.retry);
    expect(classifySendError(_http(408)), SendOutcome.retry);
    expect(classifySendError(_http(429)), SendOutcome.retry);
    expect(classifySendError(_http(503)), SendOutcome.retry);
    expect(
      classifySendError(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      ),
      SendOutcome.retry,
    );
    expect(classifySendError(StateError('x')), SendOutcome.retry);
  });
}
