import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_curves.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_row_tile.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Шаг 7. Recipe import: URL уже в поле → ингредиенты каскадом падают в список.
class RecipeStep extends StatelessWidget {
  const RecipeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ingredients = [
      l.tutorialSampleIngredient1,
      l.tutorialSampleIngredient2,
      l.tutorialSampleIngredient3,
    ];
    // Каждый ингредиент — своё окно `[start, end]` для fade + drop.
    const windows = [(0.15, 0.4), (0.35, 0.6), (0.55, 0.8)];
    const targetsY = [68.0, 126.0, 184.0];

    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 3000),
        builder: (context, t) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: _UrlField(url: l.tutorialSampleRecipeUrl),
              ),
              for (var i = 0; i < ingredients.length; i++)
                Positioned(
                  left: 0,
                  right: 0,
                  top: dropY(t, windows[i].$1, windows[i].$2, -30, targetsY[i]),
                  child: Opacity(
                    opacity: fadeIn(t, windows[i].$1, windows[i].$2),
                    child: TutorialRowTile(title: ingredients[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UrlField extends StatelessWidget {
  const _UrlField({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.input,
        border: Border.all(color: PoraColors.primary, width: 1.4),
      ),
      child: Row(
        children: [
          const Icon(
            PhosphorIconsRegular.link,
            size: 18,
            color: PoraColors.primary,
          ),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: Text(
              url,
              style: PoraText.small.copyWith(color: c.ink),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
