import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// «Streak» — сколько дней подряд юзер ведёт списки. Большая цифра + огонёк.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PoraColors.primary, PoraColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: PoraShadows.elevated,
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.fire, color: Colors.white, size: 44),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$days дней подряд',
                  style: PoraText.title.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ведёте список — не сбавляйте',
                  style: PoraText.small.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
