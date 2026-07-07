import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/recipe/presentation/widgets/dedup_banner.dart';
import 'package:pora/app/features/recipe/presentation/widgets/ingredient_row.dart';
import 'package:pora/app/features/recipe/presentation/widgets/recipe_link_field.dart';
import 'package:pora/app/features/recipe/presentation/widgets/recipe_preview_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Добавить продукты по ссылке на рецепт: парсинг + дедупликация.
@RoutePage()
class RecipeImportPage extends StatelessWidget {
  const RecipeImportPage({super.key});

  // (название, кол-во, добавлен, метка-дубль)
  static const _ingredients = <(String, String?, bool, String?)>[
    ('Спагетти', '400 г', true, null),
    ('Гуанчиале (или бекон)', '200 г', true, null),
    ('Яйца', '4 шт', false, 'уже дома'),
    ('Пармезан', '100 г', true, null),
    ('Чеснок', '2 зубчика', false, 'уже в списке'),
    ('Чёрный перец', null, true, null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PoraSpacing.screen,
              ),
              child: ScreenBackHeader(title: context.l10n.recipeImportTitle),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PoraSpacing.screen,
                  PoraSpacing.md,
                  PoraSpacing.screen,
                  PoraSpacing.md,
                ),
                children: [
                  const RecipeLinkField(url: 'eda.ru/recipe/carbonara'),
                  const SizedBox(height: PoraSpacing.lg),
                  RecipePreviewCard(
                    emoji: '🍝',
                    title: context.l10n.recipePreviewTitle,
                    meta: context.l10n.recipePreviewMeta,
                    found: context.l10n.recipePreviewFound,
                  ),
                  const SizedBox(height: PoraSpacing.md),
                  DedupBanner(text: context.l10n.recipeDedupBanner),
                  const SizedBox(height: PoraSpacing.lg),
                  SectionLabel(context.l10n.recipeIngredients),
                  PoraRowsCard(
                    children: [
                      for (final (name, qty, added, dup) in _ingredients)
                        IngredientRow(
                          name: name,
                          qty: qty,
                          added: added,
                          dup: dup,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              child: PoraPrimaryButton(
                label: context.l10n.recipeAddToListCta,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
