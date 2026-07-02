/// Позиция корзины заказа.
class CartItem {
  const CartItem({required this.emoji, required this.name, required this.unit});

  final String emoji;
  final String name;
  final int unit; // цена за единицу, ₽
}
