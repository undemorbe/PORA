import 'package:mobx/mobx.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/chat_with_pora.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';

part 'ai_chat_store.g.dart';

class AiChatStore = _AiChatStoreBase with _$AiChatStore;

abstract class _AiChatStoreBase with Store {
  _AiChatStoreBase({required this.useCase});
  final ChatWithPoraUseCase useCase;

  @observable
  ObservableList<AiMessage> history = ObservableList<AiMessage>();

  @observable
  bool isBusy = false;

  @observable
  String? errorMessage;

  @computed
  bool get isEmpty => history.isEmpty;

  /// Последний запрос упал — можно повторить без повторного ввода.
  @computed
  bool get canRetry =>
      !isBusy &&
      errorMessage != null &&
      history.isNotEmpty &&
      history.last.role == 'user';

  @action
  Future<void> send({
    required String text,
    required String languageCode,
    String? contextSummary,
    AiContext context = const AiContext(),
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isBusy) return;
    // Не копим подряд два вопроса без ответа после ошибки.
    if (canRetry) history.removeLast();
    history.add(AiMessage.user(trimmed));
    AnalyticsService.instance.logAiMessageSent();
    await _request(
      languageCode: languageCode,
      contextSummary: contextSummary,
      context: context,
    );
  }

  @action
  Future<void> retry({
    required String languageCode,
    String? contextSummary,
    AiContext context = const AiContext(),
  }) async {
    if (!canRetry) return;
    await _request(
      languageCode: languageCode,
      contextSummary: contextSummary,
      context: context,
    );
  }

  @action
  Future<void> _request({
    required String languageCode,
    String? contextSummary,
    required AiContext context,
  }) async {
    isBusy = true;
    errorMessage = null;
    final watch = Stopwatch()..start();
    final res = await useCase(
      history: List.of(history),
      languageCode: languageCode,
      contextSummary: contextSummary,
      context: context,
    );
    final content = res.isRight ? res.right.content.trim() : '';
    if (content.isNotEmpty) {
      history.add(AiMessage.assistant(content));
    } else {
      errorMessage = res.isLeft ? res.left.message : null;
      errorMessage ??= 'Empty response';
    }
    AnalyticsService.instance.logAiResponse(
      kind: 'chat',
      success: content.isNotEmpty,
      latencyMs: watch.elapsedMilliseconds,
      error: res.isLeft ? res.left.runtimeType.toString() : null,
    );
    isBusy = false;
  }

  @action
  void reset() {
    history.clear();
    isBusy = false;
    errorMessage = null;
  }
}
