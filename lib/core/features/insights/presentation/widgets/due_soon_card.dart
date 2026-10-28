import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';

/// «Пора докупить»: продукты, у которых прошёл ≥75% обычного цикла
/// покупки (`currentDay` от бэкенда = доля прошедшего цикла).
class DueSoonCard extends StatelessWidget {
  const DueSoonCard({super.key, required this.items});

  final List<PopularProductEntity> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PoraRowsCard(
      children: [
        for (final p in items)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PoraSpacing.lg,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: PoraText.itemTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: p.currentDay.clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: c.surfaceAlt,
                          color: p.currentDay >= 1
                              ? PoraColors.danger
                              : PoraColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PoraSpacing.md),
                Text(
                  _label(context, p),
                  style: PoraText.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: p.currentDay >= 1
                        ? PoraColors.danger
                        : PoraColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _label(BuildContext context, PopularProductEntity p) {
    final l = context.l10n;
    if (p.currentDay >= 1) return l.insightsDueNow;
    final left = ((1 - p.currentDay) * p.howOftenEnds).ceil();
    return left <= 0 ? l.insightsDueNow : l.insightsDueInDays(left);
  }
}
