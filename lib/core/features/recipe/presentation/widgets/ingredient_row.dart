import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_checkbox.dart';
import 'package:pora/core/internal/widgets/pora_pill.dart';

/// Строка ингредиента в разборе рецепта.
///
/// [dupLabel] — «уже в группе» (когда чекбокс отмечен = будет пропущен).
/// [dupForceLabel] — «добавим ещё» (чекбокс снят = дубликат будет добавлен).
/// Смена лейблов при toggle анимируется AnimatedSwitcher (fade + slide).
class IngredientRow extends StatelessWidget {
  const IngredientRow({
    super.key,
    required this.name,
    this.qty,
    required this.added,
    this.hasDup = false,
    this.dupLabel,
    this.dupForceLabel,
    this.onTap,
  });

  final String name;
  final String? qty;
  final bool added;
  final bool hasDup;
  final String? dupLabel;
  final String? dupForceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.lg,
          vertical: 13,
        ),
        child: Row(
          children: [
            PoraCheckbox(checked: added),
            const SizedBox(width: PoraSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: PoraText.itemTitle.copyWith(
                      color: added ? c.ink : c.textSubtle,
                    ),
                  ),
                  if (qty != null)
                    Padding(
                      padding: const EdgeInsets.only(top: PoraSpacing.xxs),
                      child: Text(
                        qty!,
                        style: PoraText.small.copyWith(color: c.textSubtle),
                      ),
                    ),
                ],
              ),
            ),
            if (hasDup) _AnimatedDupPill(added: added, dupLabel: dupLabel, dupForceLabel: dupForceLabel),
          ],
        ),
      ),
    );
  }
}

/// AnimatedSwitcher между двумя pill'ами. Тег в ключе — чтобы switcher
/// действительно проиграл fade+slide при смене вариантов.
class _AnimatedDupPill extends StatelessWidget {
  const _AnimatedDupPill({
    required this.added,
    required this.dupLabel,
    required this.dupForceLabel,
  });

  final bool added;
  final String? dupLabel;
  final String? dupForceLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // added = будет пропущен (уже есть). !added = будет добавлен принудительно.
    final showSkip = added && dupLabel != null;
    final showForce = !added && dupForceLabel != null;
    Widget child;
    if (showSkip) {
      child = PoraPill(
        key: const ValueKey('dup-skip'),
        label: dupLabel!,
        background: c.surfaceAlt,
        foreground: c.textSubtle,
      );
    } else if (showForce) {
      child = PoraPill(
        key: const ValueKey('dup-force'),
        label: dupForceLabel!,
        background: PoraColors.primary.withValues(alpha: 0.15),
        foreground: PoraColors.primaryDark,
      );
    } else {
      child = const SizedBox.shrink(key: ValueKey('dup-none'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
