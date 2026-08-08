import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/recipe/domain/chat_recipe_extractor.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Пузырь сообщения в чате. Юзер — справа, primary bg; ассистент — слева, surface bg.
/// Для ассистента детектит `<recipe>...</recipe>` — прячет тег из отображения
/// и добавляет CTA «Импортировать рецепт» под пузырём.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.fromUser,
    this.onImportRecipe,
  });

  final String text;
  final bool fromUser;

  /// Вызывается когда пользователь тапает «Импортировать рецепт».
  /// Приходит уже распарсенный `RecipeEntity`.
  final void Function(RecipeEntity)? onImportRecipe;

  @override
  Widget build(BuildContext context) {
    // Для юзерского сообщения — ничего не парсим.
    final extraction =
        fromUser ? null : ChatRecipeExtractor.extract(text);
    final display = extraction?.cleanText ?? text;
    final recipe = extraction?.recipe;
    final c = context.colors;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: child,
        ),
      ),
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          child: Column(
            crossAxisAlignment:
                fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: PoraSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: fromUser ? PoraColors.primary : c.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(fromUser ? 16 : 4),
                    bottomRight: Radius.circular(fromUser ? 4 : 16),
                  ),
                  border:
                      fromUser ? null : Border.all(color: c.border, width: 1),
                ),
                child: SelectableText(
                  display,
                  style: PoraText.bodyLarge.copyWith(
                    color: fromUser ? Colors.white : c.ink,
                    height: 1.35,
                  ),
                ),
              ),
              if (recipe != null && onImportRecipe != null)
                _RecipeCta(
                  recipe: recipe,
                  onTap: () => onImportRecipe!(recipe),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Плашка «Импортировать рецепт: TITLE · N ингредиентов» под пузырём.
class _RecipeCta extends StatelessWidget {
  const _RecipeCta({required this.recipe, required this.onTap});
  final RecipeEntity recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 6),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 4, left: 6, right: 6),
        child: PressScale(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PoraColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PoraColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIconsFill.forkKnife,
                  size: 14,
                  color: PoraColors.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${context.l10n.chatImportRecipeCta}: ${recipe.title} · ${recipe.ingredients.length}',
                    style: PoraText.small.copyWith(
                      color: PoraColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  PhosphorIconsRegular.arrowRight,
                  size: 14,
                  color: PoraColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
