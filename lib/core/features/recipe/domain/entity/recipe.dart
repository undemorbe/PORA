import 'package:equatable/equatable.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';

/// Разобранный рецепт с внешней страницы.
class RecipeEntity extends Equatable {
  final String title;
  final String? imageUrl;
  final String? servings;
  final String? foodEmoji;
  final String sourceUrl;
  final List<RecipeIngredient> ingredients;

  /// Каким способом получен рецепт (`json_ld`, `wprm`, `heuristic+ai`,
  /// `youtube+ai`, …) — для аналитики качества импорта.
  final String? extractor;

  const RecipeEntity({
    required this.title,
    required this.sourceUrl,
    required this.ingredients,
    this.imageUrl,
    this.servings,
    this.foodEmoji,
    this.extractor,
  });

  RecipeEntity copyWith({
    String? title,
    String? imageUrl,
    String? servings,
    String? foodEmoji,
    String? sourceUrl,
    List<RecipeIngredient>? ingredients,
    String? extractor,
  }) {
    return RecipeEntity(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      servings: servings ?? this.servings,
      foodEmoji: foodEmoji ?? this.foodEmoji,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      ingredients: ingredients ?? this.ingredients,
      extractor: extractor ?? this.extractor,
    );
  }

  @override
  List<Object?> get props => [
    title,
    imageUrl,
    servings,
    foodEmoji,
    sourceUrl,
    ingredients,
    extractor,
  ];
}
