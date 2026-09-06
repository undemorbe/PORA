import 'package:pora/core/features/brief/domain/entity/brief_product.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';

class AiContext {
  const AiContext({this.allProducts = const [], this.briefProducts = const []});

  final List<ProductEntity> allProducts;
  final List<BriefProductEntity> briefProducts;

  List<String> get allergens => briefProducts
      .where((product) => product.leading?.trim() == '❌❌❌')
      .map((product) => product.title.trim())
      .where((title) => title.isNotEmpty)
      .toSet()
      .toList();

  String get summary {
    final products = allProducts
        .map((product) => product.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .take(20)
        .join(', ');
    final brief = briefProducts
        .where((product) => product.leading?.trim() != '❌❌❌')
        .map((product) => product.title.trim())
        .where((title) => title.isNotEmpty)
        .toSet()
        .join(', ');
    final blocked = allergens.join(', ');

    return [
      if (products.isNotEmpty) 'All products bought by the user: $products.',
      if (brief.isNotEmpty) 'User brief products: $brief.',
      if (blocked.isNotEmpty)
        'ALLERGENS / FORBIDDEN INGREDIENTS: $blocked. Never suggest, include, or recommend these.',
    ].join(' ');
  }
}
