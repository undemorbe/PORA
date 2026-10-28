import 'package:flutter/material.dart';
import 'package:pora/core/features/insights/presentation/widgets/champion_card.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';

/// Самый покупаемый товар (см. `pickChampion`); null скрывает секцию.
class ChampionSection extends StatelessWidget {
  const ChampionSection({super.key, required this.champion});

  final CountEntry? champion;

  @override
  Widget build(BuildContext context) {
    final c = champion;
    if (c == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PoraSpacing.lg),
      child: ChampionCard(name: c.name, count: c.count),
    );
  }
}
