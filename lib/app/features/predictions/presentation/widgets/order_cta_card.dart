import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Терракотовая карточка-CTA «Заказать всё в один тап» (партнёрка с доставкой).
class OrderCtaCard extends StatelessWidget {
  const OrderCtaCard({super.key, this.onTap});

  final VoidCallback? onTap;

  static const _subtle = Color(0xFFFBE3DC);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PoraColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: PoraShadows.elevated,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Заказать всё в один тап',
                        style: PoraText.heading.copyWith(
                          fontSize: 17,
                          color: PoraColors.inkInverse,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Самокат · доставка за 15 минут',
                        style: PoraText.caption.copyWith(color: _subtle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PoraSpacing.sm),
                const PhosphorIcon(
                  PhosphorIconsFill.shoppingCart,
                  size: 26,
                  color: PoraColors.inkInverse,
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: PoraColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsFill.gift,
                      size: 14,
                      color: PoraColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '−15% на первый заказ',
                      style: PoraText.micro.copyWith(
                        fontSize: 13,
                        color: PoraColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
