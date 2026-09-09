import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// Поисковая строка списка (autofocus + кнопка закрытия).
class ListSearchField extends StatelessWidget {
  const ListSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.input,
        border: Border.all(color: c.border),
        boxShadow: PoraShadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.md),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 18,
            color: c.textMuted,
          ),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: PoraText.body.copyWith(color: c.ink),
              decoration: InputDecoration(
                hintText: context.l10n.searchHint,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: PoraSpacing.md,
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.xs),
              child: Icon(PhosphorIconsRegular.x, size: 16, color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
