import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/widgets/due_soon_card.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// «Скоро закончится» — пустой список скрывает секцию.
class DueSoonSection extends StatelessWidget {
  const DueSoonSection({super.key, required this.items});

  final List<PopularProductEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(context.l10n.insightsDueSoonTitle),
          DueSoonCard(items: items),
        ],
      ),
    );
  }
}
