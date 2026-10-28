import 'dart:math' as math;

import 'package:mobx/mobx.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/generate_tip.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_prompt_kind.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';

part 'ai_tip_store.g.dart';

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

  final math.Random _random = math.Random();
  int? _lastFallbackIndex;

  @action
  Future<void> load({
    required String topic,
    required String languageCode,
    required List<String> fallbackList,
    AiContext context = const AiContext(),
    AiPromptKind promptKind = AiPromptKind.tip,
  }) async {
    isLoading = true;
    final watch = Stopwatch()..start();
    final res = await useCase(
      topic: topic,
      languageCode: languageCode,
      context: context,
      promptKind: promptKind,
    );
    if (res.isRight && res.right.content.trim().length >= 10) {
      tip = res.right.content;
      fromFallback = false;
    } else {
      _applyFallback(fallbackList);
    }
    AnalyticsService.instance.logAiResponse(
      kind: 'tip',
      success: !fromFallback,
      latencyMs: watch.elapsedMilliseconds,
      error: res.isLeft ? res.left.runtimeType.toString() : null,
    );
    AnalyticsService.instance.logTipGenerated(fromFallback: fromFallback);
    isLoading = false;
  }

  void _applyFallback(List<String> fallbackList) {
    if (fallbackList.isEmpty) {
      tip = '';
      return;
    }
    var i = _random.nextInt(fallbackList.length);
    if (fallbackList.length > 1 && i == _lastFallbackIndex) {
      i =
          (i + 1 + _random.nextInt(fallbackList.length - 1)) %
          fallbackList.length;
    }
    _lastFallbackIndex = i;
    tip = fallbackList[i];
    fromFallback = true;
  }
}
