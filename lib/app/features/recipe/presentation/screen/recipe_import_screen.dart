import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/features/recipe/presentation/store/recipe_import_store.dart';
import 'package:pora/app/features/recipe/presentation/widgets/ingredient_row.dart';
import 'package:pora/app/features/recipe/presentation/widgets/recipe_link_field.dart';
import 'package:pora/app/features/recipe/presentation/widgets/recipe_preview_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Импорт рецепта в конкретный список.
/// Доступ только из списка — принимает `lid` (required) и `fid` (опц).
@RoutePage()
class RecipeImportPage extends StatefulWidget {
  const RecipeImportPage({super.key, required this.lid, this.fid});

  final String lid;
  final String? fid;

  @override
  State<RecipeImportPage> createState() => _RecipeImportPageState();
}

class _RecipeImportPageState extends State<RecipeImportPage> {
  late final RecipeImportStore store;
  final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store = RecipeImportStore(lid: widget.lid, fid: widget.fid);
    store.loadExisting();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    store.setUrl(urlController.text);
    await store.parse();
    if (!mounted) return;
    final err = store.errorMessage;
    if (err != null) PoraSnackbar.show(context, message: err);
  }

  Future<void> _apply() async {
    final errs = await store.addSelected();
    if (!mounted) return;
    if (errs.isEmpty) {
      PoraSnackbar.show(context, message: context.l10n.done);
      Navigator.of(context).maybePop();
    } else {
      PoraSnackbar.show(context, message: errs.first);
    }
  }

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
              child: Observer(
                builder: (context) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    PoraSpacing.screen,
                    PoraSpacing.md,
                    PoraSpacing.screen,
                    PoraSpacing.md,
                  ),
                  children: [
                    RecipeLinkField(
                      controller: urlController,
                      busy: store.isLoading,
                      onParse: _parse,
                    ),
                    const SizedBox(height: PoraSpacing.lg),
                    if (store.recipe == null && !store.isLoading)
                      const _EmptyHint()
                    else if (store.recipe != null) ...[
                      RecipePreviewCard(
                        emoji: '🍝',
                        title: store.recipe!.title,
                        meta: [
                          if (store.recipe?.servings != null)
                            store.recipe!.servings!,
                          '${store.rows.length} ${context.l10n.recipeIngredients.toLowerCase()}',
                        ].join(' · '),
                        found:
                            '${store.selectedCount}/${store.rows.length}',
                      ),
                      const SizedBox(height: PoraSpacing.lg),
                      SectionLabel(context.l10n.recipeIngredients),
                      PoraRowsCard(
                        children: [
                          for (var i = 0; i < store.rows.length; i++)
                            IngredientRow(
                              name: store.rows[i].ingredient.name,
                              qty: _formatQty(
                                store.rows[i].ingredient.quantity,
                                store.rows[i].ingredient.unit,
                              ),
                              added: store.selected.contains(i),
                              dup: store.rows[i].hasDuplicate
                                  ? context.l10n.recipeDupMark
                                  : null,
                              onTap: () => store.toggle(i),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              child: Observer(
                builder: (context) => PoraPrimaryButton(
                  label: context.l10n.recipeAddToListCta,
                  onPressed: store.rows.isEmpty ? null : _apply,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatQty(String? qty, String? unit) {
    if (qty == null && unit == null) return null;
    return [qty, unit].whereType<String>().join(' ').trim();
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xxl),
      child: Center(
        child: Text(
          context.l10n.recipeEmptyHint,
          style: PoraText.subtitle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
