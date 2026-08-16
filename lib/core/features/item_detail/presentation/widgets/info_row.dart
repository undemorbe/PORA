import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';

/// Строка «поле — значение» в карточке деталей товара.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, this.value, this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
              style: PoraText.itemTitle.copyWith(color: c.textMuted),
            ),
          ),
          if (value != null)
            Text(value!, style: PoraText.itemTitle.copyWith(color: c.ink)),
          ?trailing,
        ],
      ),
    );
  }
}
