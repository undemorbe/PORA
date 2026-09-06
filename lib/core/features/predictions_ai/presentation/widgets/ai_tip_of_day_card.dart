import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/domain/tip/fallback_tips.dart';
import 'package:pora/core/features/predictions_ai/domain/tip/tip_topic.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/generate_tip.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';
import 'package:pora/core/features/brief/domain/usecases/get_brief.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/predictions_ai/presentation/store/ai_tip_store.dart';
import 'package:pora/core/features/predictions_ai/presentation/store/tip_topics_store.dart';
import 'package:pora/core/features/predictions_ai/presentation/topic_resolver.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

class AiTipOfDayCard extends StatefulWidget {
  const AiTipOfDayCard({super.key, this.topicKey});

  final String? topicKey;

  @override
  State<AiTipOfDayCard> createState() => _AiTipOfDayCardState();
}

class _AiTipOfDayCardState extends State<AiTipOfDayCard> {
  final AiTipStore _store = AiTipStore(useCase: GetIt.I<GenerateTipUseCase>());
  final TipTopicsStore _topics = GetIt.I<TipTopicsStore>();
  final StatisticsStore _statistics = GetIt.I<StatisticsStore>();
  final math.Random _rng = math.Random();

  bool _bootstrapped = false;
  String? _currentTopicText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    _fetch();
  }

  /// Возвращает случайную тему из активного пула — если пул пуст,
  /// используем дефолтный `aiTipOfDayTopic`.
  String _pickTopic() {
    if (widget.topicKey != null) return widget.topicKey!;
    final l = context.l10n;
    final active = _topics.activeTopics;
    if (active.isEmpty) return l.aiTipOfDayTopic;
    final TipTopic chosen = active[_rng.nextInt(active.length)];
    return TopicResolver.resolve(chosen, l);
  }

  Future<void> _fetch() async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    // setState — чтобы заголовок «СОВЕТ ДНЯ · [ТЕМА]» перерисовался сразу
    // при рефреше, не дожидаясь ответа модели.
    setState(() => _currentTopicText = _pickTopic());
    await _store.load(
      topic: _currentTopicText!,
      languageCode: locale,
      fallbackList: FallbackTips.all(l),
      context: await _loadAiContext(),
    );
  }

  Future<AiContext> _loadAiContext() async {
    final brief = await GetIt.I<GetBriefUseCase>().call();
    return AiContext(
      allProducts: _statistics.allProducts.toList(),
      briefProducts: brief?.products ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.lg),
      decoration: BoxDecoration(
        color: PoraColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: PoraShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsFill.lightbulb,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _currentTopicText == null
                      ? context.l10n.aiTipOfDayLabel
                      : '${context.l10n.aiTipOfDayLabel} · ${_currentTopicText!.toUpperCase()}',
                  style: PoraText.small.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Observer(
                builder: (_) =>
                    _RefreshBtn(loading: _store.isLoading, onTap: _fetch),
              ),
            ],
          ),
          const SizedBox(height: PoraSpacing.md),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: Observer(
              builder: (_) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _Body(
                  key: ValueKey('${_store.isLoading}_${_store.tip?.length}'),
                  loading: _store.isLoading,
                  tip: _store.tip,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({super.key, required this.loading, required this.tip});
  final bool loading;
  final String? tip;

  @override
  Widget build(BuildContext context) {
    if (loading) return _Skeleton();
    return Text(
      tip ?? '',
      style: PoraText.bodyLarge.copyWith(color: Colors.white, height: 1.4),
    );
  }
}

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withValues(alpha: 0.22);
    Widget bar(double w) => Container(
      height: 12,
      width: w,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [bar(double.infinity), bar(220), bar(160)],
    );
  }
}

class _RefreshBtn extends StatelessWidget {
  const _RefreshBtn({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: loading
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                PhosphorIconsRegular.arrowClockwise,
                size: 14,
                color: Colors.white,
              ),
      ),
    );
  }
}
