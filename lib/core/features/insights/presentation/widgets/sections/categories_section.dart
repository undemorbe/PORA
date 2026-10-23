import 'package:flutter/material.dart';
import 'package:pora/core/features/add_item/presentation/item_labels.dart';
import 'package:pora/core/features/insights/presentation/widgets/category_bars.dart';
import 'package:pora/core/features/insights/presentation/widgets/insight_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

/// Доли категорий товаров (см. `StatisticsStore.categories`); пусто —
/// секция скрыта.
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key, required this.categories});

  final List<CountEntry> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final total = categories.fold<int>(0, (a, e) => a + e.count);
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.lg),
      child: InsightCard(
        title: context.l10n.insightsCategoriesTitle,
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.lg,
          PoraSpacing.lg,
          PoraSpacing.lg,
          PoraSpacing.sm,
        ),
        child: CategoryBars(
          items: [
            for (final c in categories)
              CategoryBar(
                // Канонические русские названия секций → язык интерфейса
                name: context.l10n.sectionName(c.name),
                share: total == 0 ? 0 : c.count / total,
              ),
          ],
        ),
      ),
    );
  }
}
