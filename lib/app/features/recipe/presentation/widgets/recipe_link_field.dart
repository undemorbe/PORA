import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Поле ссылки на рецепт + кнопка «Разобрать».
class RecipeLinkField extends StatelessWidget {
  const RecipeLinkField({super.key, required this.url, this.onParse});

  final String url;
  final VoidCallback? onParse;

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
            child: Text(
              url,
              style: PoraText.body.copyWith(color: PoraColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onParse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: PoraColors.primary,
                borderRadius: PoraRadii.md,
              ),
              child: Text(
                'Разобрать',
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
