import 'package:flutter/material.dart';
import 'package:pora/app/features/add_item/presentation/widgets/quantity_stepper.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Строка корзины: эмодзи · название · счётчик · сумма.
class CartRow extends StatelessWidget {
  const CartRow({
    super.key,
    required this.emoji,
    required this.name,
    required this.qty,
    required this.priceText,
    this.onDecrement,
    this.onIncrement,
  });

  final String emoji;
  final String name;
  final int qty;
  final String priceText;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(child: Text(name, style: PoraText.itemTitle)),
          QuantityStepper(
            value: qty,
            onDecrement: onDecrement,
            onIncrement: onIncrement,
          ),
          const SizedBox(width: PoraSpacing.md),
          SizedBox(
            width: 64,
            child: Text(
              priceText,
              textAlign: TextAlign.right,
              style: PoraText.caption.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: PoraColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
