import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// «Streak» — сколько дней подряд юзер пользуется Pora + личный рекорд.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days, this.best = 0});

  final int days;
  final int best;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final onAccent = Colors.white.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PoraColors.primary, PoraColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
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
                  l.insightsStreakDays(days),
                  style: PoraText.title.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  days == 0 ? l.insightsStreakStart : l.insightsStreakSubtitle,
                  style: PoraText.small.copyWith(color: onAccent),
                ),
              ],
            ),
          ),
          if (best > days) ...[
            const SizedBox(width: PoraSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: PoraRadii.pill,
              ),
              child: Text(
                l.insightsStreakBest(best),
                style: PoraText.micro.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
