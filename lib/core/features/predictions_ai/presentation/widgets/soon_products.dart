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
  });

  final List<PopularProductEntity> products;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onDismiss;

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
    final locale = Localizations.localeOf(context).languageCode;
    final every = product.howOftenEnds > 0
        ? (locale == 'ru'
              ? '~раз в ${product.howOftenEnds} дней'
              : '~every ${product.howOftenEnds}d')
        : (locale == 'ru' ? 'Покупаете регулярно' : 'Bought regularly');
    final lastBought = product.currentDay > 0 && product.howOftenEnds > 0
        ? (product.howOftenEnds / product.currentDay).round()
        : 0;
    final meta = lastBought > 0
        ? (locale == 'ru'
              ? '$every · куплено $lastBought дн. назад'
              : '$every · bought ${lastBought}d ago')
        : every;
    return PredictionEntity(emoji: '🛒', name: product.name, meta: meta);
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
