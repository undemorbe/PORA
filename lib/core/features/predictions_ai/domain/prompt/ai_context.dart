import 'package:pora/core/features/brief/domain/entity/brief_product.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';

/// Маркер аллергена в brief-продуктах (leading).
const String kAllergenMarker = '❌❌❌';

/// Собирает конкретный, структурированный контекст о пользователе для AI:
/// аллергены (строгий запрет), что нужно купить, что уже есть (кладовая),
/// срочное, категории покупок, пожелания. Чем конкретнее — тем полезнее ответ.
class AiContext {
  const AiContext({this.allProducts = const [], this.briefProducts = const []});

  final List<ProductEntity> allProducts;
  final List<BriefProductEntity> briefProducts;

  /// Аллергены / запрещённые ингредиенты (brief-продукты с маркером [kAllergenMarker]).
  List<String> get allergens => briefProducts
      .where((product) => product.leading?.trim() == kAllergenMarker)
      .map((product) => product.title.trim())
      .where((title) => title.isNotEmpty)
      .toSet()
      .toList();

  String _labeled(ProductEntity p) {
    final name = p.name.trim();
    if (p.quantity > 0) {
      final unit = p.unit.trim().isNotEmpty ? ' ${p.unit.trim()}' : '';
      return '$name (${p.quantity}$unit)';
    }
    return name;
  }

  String get summary {
    final parts = <String>[];

    final blocked = allergens;
    if (blocked.isNotEmpty) {
      parts.add(
        'ALLERGENS — strictly forbidden. Never suggest, include, or recommend '
        'these, dishes that typically contain them, or their derivatives; '
        'offer a safe alternative instead: ${blocked.join(', ')}.',
      );
    }

    final needed = allProducts
        .where((p) => !p.checked)
        .map(_labeled)
        .where((s) => s.isNotEmpty)
        .toSet()
        .take(15)
        .toList();
    if (needed.isNotEmpty) {
      parts.add('On the shopping list now (still to buy): ${needed.join(', ')}.');
    }

    final urgent = allProducts
        .where((p) => p.urgent && !p.checked)
        .map((p) => p.name.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    if (urgent.isNotEmpty) {
      parts.add('Marked urgent (needs soon): ${urgent.join(', ')}.');
    }

    final have = allProducts
        .where((p) => p.checked)
        .map((p) => p.name.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .take(20)
        .toList();
    if (have.isNotEmpty) {
      parts.add('Pantry / recently bought (already has): ${have.join(', ')}.');
    }

    final categories = allProducts
        .map((p) => p.section.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .take(8)
        .toList();
    if (categories.isNotEmpty) {
      parts.add('Usually shops these categories: ${categories.join(', ')}.');
    }

    final wishes = briefProducts
        .where((p) => p.leading?.trim() != kAllergenMarker)
        .map((p) => p.title.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    if (wishes.isNotEmpty) {
      parts.add('User brief / wishes: ${wishes.join(', ')}.');
    }

    return parts.join('\n');
  }
}
