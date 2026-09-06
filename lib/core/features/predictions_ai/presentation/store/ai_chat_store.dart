import 'package:mobx/mobx.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/ai_message.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/chat_with_pora.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';

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

  @action
  Future<void> send({
    required String text,
    required String languageCode,
    String? contextSummary,
    AiContext context = const AiContext(),
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isBusy) return;
    history.add(AiMessage.user(trimmed));
    isBusy = true;
    errorMessage = null;
    final res = await useCase(
      history: List.of(history),
      languageCode: languageCode,
      contextSummary: contextSummary,
      context: context,
    );
    if (res.isRight) {
      history.add(AiMessage.assistant(res.right.content));
    } else {
      errorMessage = res.left.message;
    }
    isBusy = false;
  }

  @action
  void reset() {
    history.clear();
    isBusy = false;
    errorMessage = null;
  }
}
