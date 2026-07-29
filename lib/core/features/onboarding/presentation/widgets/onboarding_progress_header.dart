import 'package:flutter/material.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Шапка онбординга: вордмарк «Pora», «Шаг N из total» и прогресс-бар.
class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.step,
    this.total = 4,
  });

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pora',
              style: TextStyle(
                fontFamily: kPoraFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PoraColors.primary,
              ),
            ),
            Text(
              context.l10n.onboardingStep(step, total),
              style: PoraText.caption.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: PoraSpacing.lg),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 6,
            backgroundColor: PoraColors.progressTrack,
            color: PoraColors.primary,
          ),
        ),
      ],
    );
  }
}
