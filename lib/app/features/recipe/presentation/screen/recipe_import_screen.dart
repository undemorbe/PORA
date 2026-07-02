import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/recipe/presentation/widgets/dedup_banner.dart';
import 'package:pora/app/features/recipe/presentation/widgets/ingredient_row.dart';
import 'package:pora/app/features/recipe/presentation/widgets/recipe_link_field.dart';
import 'package:pora/app/features/recipe/presentation/widgets/recipe_preview_card.dart';
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: PoraSpacing.screen),
              child: ScreenBackHeader(title: 'Рецепт по ссылке'),
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
                  const RecipePreviewCard(
                    emoji: '🍝',
                    title: 'Паста Карбонара',
                    meta: 'eda.ru · 25 мин · 2 порции',
                    found: '6 ингредиентов найдено',
                  ),
                  const SizedBox(height: PoraSpacing.md),
                  const DedupBanner(
                    text:
                        '2 совпадения убрали, чтобы не дублировать с вашим списком',
                  ),
                  const SizedBox(height: PoraSpacing.lg),
                  const SectionLabel('Ингредиенты'),
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
                label: 'Добавить 4 продукта в список',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
