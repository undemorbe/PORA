import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Универсальная строка-плитка «продукт в списке».
///
/// - [offsetX] сдвигает содержимое по X (нужно для slidable-имитации).
/// - [opacity] клампится в `[0, 1]` — защита от овершутов easeOutBack.
/// - Если [leading] не задан — рисуется чекбокс, реагирующий на [checked].
class TutorialRowTile extends StatelessWidget {
  const TutorialRowTile({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.checked = false,
    this.offsetX = 0,
    this.opacity = 1,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool checked;
  final double offsetX;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: PoraRadii.md,
            border: Border.all(color: c.border, width: 1),
          ),
          child: Row(
            children: [
              leading ?? _Checkbox(checked: checked),
              const SizedBox(width: PoraSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: PoraText.itemTitle.copyWith(
                    decoration: checked ? TextDecoration.lineThrough : null,
                    color: checked ? c.textMuted : c.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? PoraColors.primary : c.surfaceAlt,
        borderRadius: PoraRadii.sm,
        border: Border.all(
          color: checked ? PoraColors.primary : c.border,
          width: 1.4,
        ),
      ),
      child: checked
          ? const Icon(
              PhosphorIconsRegular.check,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }
}
