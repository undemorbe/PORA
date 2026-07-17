import 'package:flutter/material.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

/// Итоговая карточка заказа (товары, скидка, доставка, итого).
class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.goods,
    required this.discount,
    required this.total,
  });

  final String goods;
  final String discount;
  final String total;

  @override
  Widget build(BuildContext context) {
    return PoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _SumRow(context.l10n.orderSummaryGoods, goods),
          _SumRow(
            context.l10n.orderSummaryDiscount,
            discount,
            color: PoraColors.success,
          ),
          _SumRow(
            context.l10n.orderSummaryDelivery,
            context.l10n.orderSummaryFree,
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          _SumRow(context.l10n.orderSummaryTotal, total, total: true),
        ],
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow(this.label, this.value, {this.color, this.total = false});

  final String label;
  final String value;
  final Color? color;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final labelStyle = total
        ? PoraText.heading.copyWith(fontSize: 17)
        : PoraText.body.copyWith(fontSize: 14, color: PoraColors.textSecondary);
    final valueStyle = total
        ? PoraText.title.copyWith(fontSize: 18)
        : PoraText.itemTitle.copyWith(
            fontSize: 14,
            color: color ?? context.colors.ink,
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
