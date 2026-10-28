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

  RecipeIngredient copyWith({
    String? name,
    String? raw,
    String? quantity,
    String? unit,
    String? note,
  }) {
    return RecipeIngredient(
      name: name ?? this.name,
      raw: raw ?? this.raw,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [name, raw, quantity, unit, note];
}
