import 'package:equatable/equatable.dart';

/// Ингредиент рецепта.
/// `quantity` и `unit` парсятся из строки типа "400 г спагетти" —
/// могут остаться null если распознавание не удалось.
class RecipeIngredient extends Equatable {
  final String name;
  final String? quantity;
  final String? unit;
  final String raw;

  const RecipeIngredient({
    required this.name,
    this.quantity,
    this.unit,
    required this.raw,
  });

  @override
  List<Object?> get props => [name, quantity, unit, raw];
}
