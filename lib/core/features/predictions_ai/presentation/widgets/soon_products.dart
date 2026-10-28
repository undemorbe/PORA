import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/prediction.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/prediction_card.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';

/// Список «скоро закончится» — карточки-предсказания с dismiss.
class SoonProducts extends StatelessWidget {
  const SoonProducts({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.onDismiss,
    required this.onAdd,
  });

  final List<PopularProductEntity> products;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onDismiss;
  final ValueChanged<PopularProductEntity> onAdd;

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.md),
        child: Text(
          errorMessage ?? context.l10n.insightsEmpty,
          textAlign: TextAlign.center,
          style: PoraText.small.copyWith(color: context.colors.textSubtle),
        ),
      );
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          for (var index = 0; index < products.length; index++)
            FadeSlideIn(
              key: ValueKey(products[index].name),
              delay: Duration(milliseconds: index * 80),
              child: Padding(
                padding: const EdgeInsets.only(bottom: PoraSpacing.md),
                child: PredictionCard(
                  prediction: _prediction(context, products[index]),
                  tileColor: _tileColor(index),
                  onAdd: () => onAdd(products[index]),
                  onDismiss: () => onDismiss(products[index].name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PredictionEntity _prediction(
    BuildContext context,
    PopularProductEntity product,
  ) {
    final l10n = context.l10n;
    final cycle = product.howOftenEnds;
    final every = cycle <= 0
        ? l10n.predictionBoughtRegularly
        : cycle == 1
        ? l10n.predictionEveryDay
        : l10n.predictionEvery(cycle);
    final days = daysSinceBought(product);
    final meta = days == null
        ? every
        : '$every · ${switch (days) {
            0 => l10n.predictionBoughtToday,
            1 => l10n.predictionBoughtYesterday,
            _ => l10n.predictionBoughtDaysAgo(days),
          }}';
    return PredictionEntity(emoji: '🛒', name: product.name, meta: meta);
  }

  /// Дней с последней покупки. `currentDay` с сервера — доля прошедшего
  /// цикла (часы с покупки / длина цикла / 24), поэтому дни = доля × цикл.
  /// `null`, если данных о цикле нет.
  @visibleForTesting
  static int? daysSinceBought(PopularProductEntity product) {
    if (product.howOftenEnds <= 0 || product.currentDay < 0) return null;
    return (product.currentDay * product.howOftenEnds).floor();
  }

  Color _tileColor(int index) {
    const colors = [
      PoraColors.sandSoft,
      PoraColors.sandMocha,
      PoraColors.sandWheat,
    ];
    return colors[index % colors.length];
  }
}
