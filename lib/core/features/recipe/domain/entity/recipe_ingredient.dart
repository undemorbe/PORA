import 'package:equatable/equatable.dart';

class RecipeIngredient extends Equatable {
  const RecipeIngredient({
    required this.name,
    required this.raw,
    this.quantity,
    this.unit,
    this.note,
  });

  final String name;
  final String raw;
  final String? quantity;
  final String? unit;
  final String? note;

  @override
  // TODO: implement props
  List<Object?> get props => [name, raw, quantity, unit, note];
}
