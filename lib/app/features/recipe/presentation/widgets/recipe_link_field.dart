import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Поле ссылки на рецепт + кнопка «Разобрать».
class RecipeLinkField extends StatelessWidget {
  const RecipeLinkField({
    super.key,
    required this.controller,
    required this.onParse,
    this.busy = false,
  });

  final TextEditingController controller;
  final VoidCallback onParse;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: PoraRadii.input,
        border: Border.all(color: PoraColors.border),
      ),
      child: Row(
        children: [
          const PhosphorIcon(
            PhosphorIconsRegular.link,
            size: 16,
            color: PoraColors.textSubtle,
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              autocorrect: false,
              onSubmitted: (_) => onParse(),
              style: PoraText.body.copyWith(color: PoraColors.textSecondary),
              decoration: const InputDecoration(
                hintText: 'https://…',
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          GestureDetector(
            onTap: busy ? null : onParse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: busy ? PoraColors.textMuted : PoraColors.primary,
                borderRadius: PoraRadii.md,
              ),
              child: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PoraColors.inkInverse,
                      ),
                    )
                  : Text(
                      context.l10n.recipeParseButton,
                      style: PoraText.micro.copyWith(
                        fontSize: 13,
                        color: PoraColors.inkInverse,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
