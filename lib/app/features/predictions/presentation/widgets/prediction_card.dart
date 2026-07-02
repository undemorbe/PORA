import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/predictions/domain/entity/prediction.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

/// Карточка предсказания: плитка-эмодзи · название/мета · «＋ В список» / «Не надо».
class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
    required this.tileColor,
    this.onAdd,
    this.onDismiss,
  });

  final Prediction prediction;
  final Color tileColor;
  final VoidCallback? onAdd;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return PoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: PoraSizes.avatarMd,
            height: PoraSizes.avatarMd,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tileColor, shape: BoxShape.circle),
            child: Text(prediction.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prediction.name, style: PoraText.button),
                const SizedBox(height: 3),
                Text(
                  prediction.meta,
                  style: PoraText.small.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: PoraSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: PoraColors.primary,
                    borderRadius: PoraRadii.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsBold.plus,
                        size: 13,
                        color: PoraColors.inkInverse,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'В список',
                        style: PoraText.micro.copyWith(
                          fontSize: 13,
                          color: PoraColors.inkInverse,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 7),
              GestureDetector(
                onTap: onDismiss,
                child: Text('Не надо', style: PoraText.small),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
