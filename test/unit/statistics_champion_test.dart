import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/insights/domain/entity/popular_product.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';

PopularProductEntity _popular(String name, int quantity) =>
    PopularProductEntity(
      name: name,
      quantity: quantity,
      howOftenEnds: 0,
      currentDay: 0,
    );

void main() {
  test('server top wins when it has purchases', () {
    final champion = pickChampion(
      [_popular('Молоко', 12)],
      const [CountEntry('Хлеб', 3)],
    );
    expect(champion?.name, 'Молоко');
    expect(champion?.count, 12);
  });

  test('falls back to local top when server is empty or zero', () {
    expect(
      pickChampion(
        [_popular('Молоко', 0)],
        const [CountEntry('Хлеб', 3)],
      )?.name,
      'Хлеб',
    );
    expect(pickChampion(const [], const [CountEntry('Хлеб', 3)])?.count, 3);
  });

  test('null when nothing is known', () {
    expect(pickChampion(const [], const []), isNull);
  });
}
