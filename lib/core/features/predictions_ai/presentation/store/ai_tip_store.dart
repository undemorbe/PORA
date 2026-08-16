import 'package:mobx/mobx.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/generate_tip.dart';

part 'ai_tip_store.g.dart';

/// Store для карточки «Совет дня». Держит текст, состояние загрузки и флаг
/// фолбэка. Сам не тянет l10n — fallback-текст приходит извне (из UI).
class AiTipStore = _AiTipStoreBase with _$AiTipStore;

abstract class _AiTipStoreBase with Store {
  _AiTipStoreBase({required this.useCase});
  final GenerateTipUseCase useCase;

  @observable
  String? tip;

  @observable
  bool isLoading = true;

  @observable
  bool fromFallback = false;

  int _fallbackCounter = 0;

  @action
  Future<void> load({
    required String topic,
    required String languageCode,
    required List<String> fallbackList,
  }) async {
    isLoading = true;
    final res = await useCase(topic: topic, languageCode: languageCode);
    if (res.isRight && res.right.content.trim().length >= 10) {
      tip = res.right.content;
      fromFallback = false;
    } else {
      _applyFallback(fallbackList);
    }
    isLoading = false;
  }

  void _applyFallback(List<String> fallbackList) {
    if (fallbackList.isEmpty) {
      tip = '';
      return;
    }
    final i = (_fallbackCounter++).abs() % fallbackList.length;
    tip = fallbackList[i];
    fromFallback = true;
  }
}
