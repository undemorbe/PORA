import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Куда добавить рецепт. Возвращает `RecipeTargetChoice` через `Navigator.pop`.
enum RecipeTargetKind { createPersonal, createShared, existing }

class RecipeTargetChoice {
  const RecipeTargetChoice({required this.kind, this.existingLid});
  final RecipeTargetKind kind;
  final String? existingLid;
}

Future<RecipeTargetChoice?> showRecipeTargetSheet(
  BuildContext context, {
  required String recipeTitle,
}) {
  return showModalBottomSheet<RecipeTargetChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RecipeTargetSheet(recipeTitle: recipeTitle),
  );
}

class _RecipeTargetSheet extends StatelessWidget {
  const _RecipeTargetSheet({required this.recipeTitle});
  final String recipeTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final groups = GetIt.I<GroupsStore>();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                PoraSpacing.sm,
                PoraSpacing.screen,
                PoraSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Куда добавить рецепт?',
                    style: PoraText.title.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '«$recipeTitle»',
                    style: PoraText.small.copyWith(color: c.textSubtle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) => ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    PoraSpacing.screen,
                    0,
                    PoraSpacing.screen,
                    PoraSpacing.xxl,
                  ),
                  children: [
                    _CreateRow(
                      icon: PhosphorIconsFill.usersThree,
                      title: 'Создать общую группу',
                      subtitle: 'Ссылка для приглашения partners',
                      accent: true,
                      onTap: () => Navigator.of(context).pop(
                        const RecipeTargetChoice(
                          kind: RecipeTargetKind.createShared,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CreateRow(
                      icon: PhosphorIconsFill.user,
                      title: 'Создать личный список',
                      subtitle: 'Только для вас',
                      onTap: () => Navigator.of(context).pop(
                        const RecipeTargetChoice(
                          kind: RecipeTargetKind.createPersonal,
                        ),
                      ),
                    ),
                    if (groups.groups.isNotEmpty) ...[
                      const SizedBox(height: PoraSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Добавить в существующий',
                          style: PoraText.small.copyWith(
                            color: c.textSubtle,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      for (final g in groups.groups)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _ExistingRow(
                            emoji: g.familyId == null ? '👤' : '👥',
                            title: g.list.name,
                            subtitle: g.familyId == null
                                ? 'Личный'
                                : '${g.members.length} участ.',
                            onTap: () => Navigator.of(context).pop(
                              RecipeTargetChoice(
                                kind: RecipeTargetKind.existing,
                                existingLid: g.list.id,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRow extends StatelessWidget {
  const _CreateRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PoraSpacing.md),
        decoration: BoxDecoration(
          color: accent
              ? PoraColors.primary.withValues(alpha: 0.12)
              : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent
                ? PoraColors.primary.withValues(alpha: 0.4)
                : c.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: PoraColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: PoraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PoraText.itemTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: PoraText.small.copyWith(color: c.textSubtle),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              size: 14,
              color: PoraColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExistingRow extends StatelessWidget {
  const _ExistingRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border, width: 1),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: PoraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PoraText.itemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: PoraText.small.copyWith(color: c.textSubtle),
                  ),
                ],
              ),
            ),
            const Icon(
              PhosphorIconsRegular.arrowRight,
              size: 16,
              color: PoraColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
