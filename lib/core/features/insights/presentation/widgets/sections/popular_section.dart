import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/frequency_row.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';

/// Популярные товары с сервера: загрузка / ошибка-или-пусто / список.
class PopularSection extends StatelessWidget {
  const PopularSection({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<PopularProductEntity> products;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: PoraSpacing.lg),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.md),
        child: Text(
          errorMessage ?? context.l10n.insightsEmpty,
          style: PoraText.small.copyWith(color: context.colors.textSubtle),
          textAlign: TextAlign.center,
        ),
      );
    }
    final l = context.l10n;
    final top = products.first.quantity;
    return PoraRowsCard(
      children: [
        for (final p in products.take(6))
          FrequencyRow(
            name: p.name,
            sub: p.howOftenEnds > 0
                ? l.insightsFreqEvery(p.howOftenEnds)
                : '×${p.quantity}',
            pct: top == 0 ? 0 : p.quantity / top,
          ),
      ],
    );
  }
}
