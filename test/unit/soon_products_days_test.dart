import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/soon_products.dart';

PopularProductEntity _product({required int cycle, required double share}) =>
    PopularProductEntity(
      name: 'молоко',
      quantity: 1,
      howOftenEnds: cycle,
      currentDay: share,
    );

void main() {
  test('days since bought = share of cycle × cycle length', () {
    // куплено 1 час назад при цикле 1 день: share = 1/24
    expect(SoonProducts.daysSinceBought(_product(cycle: 1, share: 1 / 24)), 0);
    // половина 10-дневного цикла — 5 дней
    expect(SoonProducts.daysSinceBought(_product(cycle: 10, share: 0.5)), 5);
    // цикл пройден на 120% при 7 днях — 8 дней
    expect(SoonProducts.daysSinceBought(_product(cycle: 7, share: 1.2)), 8);
  });

  test('no cycle data — no days', () {
    expect(
      SoonProducts.daysSinceBought(_product(cycle: 0, share: 0.5)),
      isNull,
    );
  });
}
