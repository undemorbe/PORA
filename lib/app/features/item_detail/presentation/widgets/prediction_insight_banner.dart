import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Баннер с инсайтом предсказания пополнения на карточке товара.
class PredictionInsightBanner extends StatelessWidget {
  const PredictionInsightBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: const BoxDecoration(
        color: PoraColors.primaryTint,
        borderRadius: PoraRadii.input,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PhosphorIcon(
            PhosphorIconsRegular.chartBar,
            size: 16,
            color: PoraColors.primaryDark,
          ),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: PoraText.caption.copyWith(
                color: PoraColors.primaryDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
