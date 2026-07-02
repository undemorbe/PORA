import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Строка «поле — значение» в карточке деталей товара.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, this.value, this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: PoraText.itemTitle.copyWith(color: PoraColors.textMuted),
            ),
          ),
          if (value != null) Text(value!, style: PoraText.itemTitle),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
