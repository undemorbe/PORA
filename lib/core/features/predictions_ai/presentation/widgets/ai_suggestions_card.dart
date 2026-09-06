import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/brief/domain/usecases/get_brief.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_prompt_kind.dart';
import 'package:pora/core/features/predictions_ai/domain/tip/fallback_tips.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/generate_tip.dart';
import 'package:pora/core/features/predictions_ai/presentation/store/ai_tip_store.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

class AiSuggestionsCard extends StatefulWidget {
  const AiSuggestionsCard({super.key});

  @override
  State<AiSuggestionsCard> createState() => _AiSuggestionsCardState();
}

class _AiSuggestionsCardState extends State<AiSuggestionsCard> {
  final AiTipStore _store = AiTipStore(useCase: GetIt.I<GenerateTipUseCase>());
  final StatisticsStore _statistics = GetIt.I<StatisticsStore>();
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    await _statistics.loadAll();
    final brief = await GetIt.I<GetBriefUseCase>().call();
    if (!mounted) return;
    final locale = Localizations.localeOf(context).languageCode;
    await _store.load(
      topic: context.l10n.predictionsAiSuggestionsTopic,
      languageCode: locale,
      fallbackList: FallbackTips.all(context.l10n),
      promptKind: AiPromptKind.suggestions,
      context: AiContext(
        allProducts: _statistics.allProducts.toList(),
        briefProducts: brief?.products ?? const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final loading = _store.isLoading;
        final text = _store.tip?.trim() ?? '';
        return Container(
          padding: const EdgeInsets.all(PoraSpacing.lg),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    PhosphorIconsFill.sparkle,
                    size: 18,
                    color: PoraColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.predictionsAiSuggestionsTitle,
                      style: PoraText.itemTitle.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.refresh,
                    onPressed: loading ? null : _load,
                    icon: const Icon(
                      PhosphorIconsRegular.arrowsClockwise,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (loading)
                const LinearProgressIndicator(minHeight: 2)
              else
                Text(
                  text,
                  style: PoraText.body.copyWith(
                    color: context.colors.textMuted,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
