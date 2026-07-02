import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/order/domain/entity/cart_item.dart';
import 'package:pora/app/features/order/presentation/widgets/cart_row.dart';
import 'package:pora/app/features/order/presentation/widgets/order_summary.dart';
import 'package:pora/app/features/order/presentation/widgets/slot_tile.dart';
import 'package:pora/app/features/order/presentation/widgets/store_card.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Заказ/чекаут: корзина, счётчики, слот доставки, итог, CTA.
@RoutePage()
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _items = <CartItem>[
    CartItem(emoji: '🥛', name: 'Молоко 2 л', unit: 98),
    CartItem(emoji: '🍞', name: 'Хлеб', unit: 65),
    CartItem(emoji: '🥦', name: 'Брокколи 400 г', unit: 189),
    CartItem(emoji: '🧀', name: 'Пармезан 100 г', unit: 320),
  ];
  static const _slots = <(String, String)>[
    ('Сейчас · 15 минут', '+₽0'),
    ('Через 2 часа', 'бесплатно'),
    ('Завтра, 8:00–10:00', 'бесплатно'),
  ];

  final List<int> _qty = [1, 2, 1, 1];
  int _slot = 0;

  int get _goods {
    var s = 0;
    for (var i = 0; i < _items.length; i++) {
      s += _items[i].unit * _qty[i];
    }
    return s;
  }

  int get _discount => (_goods * 0.15).round();
  int get _total => _goods - _discount;

  static String _rub(int n) {
    final s = n.toString();
    final b = StringBuffer('₽');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PoraSpacing.screen,
                  6,
                  PoraSpacing.screen,
                  PoraSpacing.md,
                ),
                children: [
                  Text('Заказ', style: PoraText.title),
                  const SizedBox(height: PoraSpacing.lg),

                  const StoreCard(),
                  const SizedBox(height: PoraSpacing.lg),

                  const SectionLabel('Корзина'),
                  PoraRowsCard(
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        CartRow(
                          emoji: _items[i].emoji,
                          name: _items[i].name,
                          qty: _qty[i],
                          priceText: _rub(_items[i].unit * _qty[i]),
                          onDecrement: () => setState(
                            () => _qty[i] = _qty[i] > 1 ? _qty[i] - 1 : 1,
                          ),
                          onIncrement: () => setState(() => _qty[i]++),
                        ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.lg),

                  const SectionLabel('Когда доставить'),
                  for (var i = 0; i < _slots.length; i++) ...[
                    SlotTile(
                      label: _slots[i].$1,
                      price: _slots[i].$2,
                      selected: _slot == i,
                      onTap: () => setState(() => _slot = i),
                    ),
                    if (i < _slots.length - 1) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: PoraSpacing.lg),

                  OrderSummary(
                    goods: _rub(_goods),
                    discount: '−${_rub(_discount)}',
                    total: _rub(_total),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              child: PoraPrimaryButton(
                label: 'Заказать в Самокате · ${_rub(_total)}',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
