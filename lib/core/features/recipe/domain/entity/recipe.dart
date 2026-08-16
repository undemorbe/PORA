import 'package:equatable/equatable.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

/// Разобранный рецепт с внешней страницы.
class RecipeEntity extends Equatable {
  final String title;
  final String? imageUrl;
  final String? servings;
  final String sourceUrl;
  final List<RecipeIngredient> ingredients;

  const RecipeEntity({
    required this.title,
    required this.sourceUrl,
    required this.ingredients,
    this.imageUrl,
    this.servings,
  });

  @override
  List<Object?> get props => [
    title,
    imageUrl,
    servings,
    sourceUrl,
    ingredients,
  ];
}
