import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/core/features/recipe/presentation/store/recipe_import_store.dart';
import 'package:pora/core/features/recipe/presentation/widgets/dedup_banner.dart';
import 'package:pora/core/features/recipe/presentation/widgets/ingredient_row.dart';
import 'package:pora/core/features/recipe/presentation/widgets/recipe_link_field.dart';
import 'package:pora/core/features/recipe/presentation/widgets/recipe_preview_card.dart';
import 'package:pora/core/features/recipe/presentation/widgets/recipe_target_sheet.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_guard.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';
import 'package:pora/core/internal/widgets/screen_back_header.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

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
    store = RecipeImportStore(lid: widget.lid);
    store.loadExisting();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    store.setUrl(urlController.text);
    final locale = Localizations.localeOf(context).languageCode;
    await store.parse(languageCode: locale);
    if (!mounted) return;
    final err = store.errorMessage;
    if (err != null) PoraSnackbar.show(context, message: err);
  }

  Future<void> _apply() async {
    if (!await ConnectivityGuard.checkWrite(context)) return;
    final errs = await store.addSelected();
    if (!mounted) return;
    if (errs.isEmpty) {
      PoraSnackbar.show(context, message: context.l10n.done);
      Navigator.of(context).maybePop();
    } else {
      PoraSnackbar.show(context, message: errs.first);
    }
  }

  Future<void> _pickTargetAndCreate() async {
    if (!await ConnectivityGuard.checkWrite(context)) return;
    final r = store.recipe;
    if (r == null) return;
    if (!context.mounted) return;
    final choice = await showRecipeTargetSheet(context, recipeTitle: r.title);
    if (choice == null || !mounted) return;

    String? outcome;
    switch (choice.kind) {
      case RecipeTargetKind.createShared:
        outcome = await store.createSharedGroupFromRecipe();
        break;
      case RecipeTargetKind.createPersonal:
        outcome = await store.createListFromRecipe();
        break;
      case RecipeTargetKind.existing:
        final errs =
            await store.addRecipeToExistingList(choice.existingLid!);
        if (errs.isNotEmpty) {
          outcome = null;
        } else {
          outcome = choice.existingLid;
        }
        break;
    }

    if (!mounted) return;
    if (outcome == null) {
      PoraSnackbar.show(
        context,
        message: store.errorMessage ?? context.l10n.commonError,
      );
      return;
    }
    PoraSnackbar.show(context, message: context.l10n.done);
    Navigator.of(context).maybePop();
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
                        found: '${store.selectedCount}/${store.rows.length}',
                      ),
                      const SizedBox(height: PoraSpacing.md),
                      _CreateListCta(
                        title: store.recipe!.title,
                        onTap: _pickTargetAndCreate,
                      ),
                      // Dedup banner — только пока хотя бы один dup помечен «пропустить».
                      AnimatedSize(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SizeTransition(
                              sizeFactor: anim,
                              axisAlignment: -1,
                              child: child,
                            ),
                          ),
                          child: store.dupSkipCount > 0
                              ? Padding(
                                  key: const ValueKey('dedup-shown'),
                                  padding: const EdgeInsets.only(
                                    bottom: PoraSpacing.md,
                                  ),
                                  child: DedupBanner(
                                    text: context.l10n
                                        .recipeDedupBannerMany(store.dupSkipCount),
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('dedup-hidden'),
                                ),
                        ),
                      ),
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
                              hasDup: store.rows[i].hasDuplicate,
                              dupLabel: context.l10n.recipeDupMark,
                              dupForceLabel: context.l10n.recipeDupForceMark,
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

/// CTA-плашка «Создать список "TITLE"» — создаёт новый personal list
/// с именем рецепта и заливает туда все ингредиенты.
class _CreateListCta extends StatelessWidget {
  const _CreateListCta({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.md,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: PoraColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: PoraColors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_shopping_cart_rounded,
              color: PoraColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.recipeCreateListCta,
                    style: PoraText.itemTitle.copyWith(
                      color: PoraColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '«$title»',
                    style: PoraText.small.copyWith(
                      color: PoraColors.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: PoraColors.primary,
              size: 14,
            ),
          ],
        ),
      ),
    );
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
