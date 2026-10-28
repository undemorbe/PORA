import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';

/// Одиночное поле в карточке (для ключа) с иконкой слева и опциональным
/// trailing (глаз).
class AiConfigFieldCard extends StatelessWidget {
  const AiConfigFieldCard({
    super.key,
    required this.icon,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.enabled = true,
    this.trailing,
  });

  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool enabled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return PoraRowsCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PoraSpacing.md,
            vertical: PoraSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, color: context.colors.textMuted),
              const SizedBox(width: PoraSpacing.md),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: PoraText.body,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ],
    );
  }
}

/// Строка модели: иконка + label сверху, поле ввода снизу.
class AiConfigFieldTile extends StatelessWidget {
  const AiConfigFieldTile({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.hint,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.md,
        vertical: PoraSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.textMuted),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: PoraText.itemTitle),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: PoraText.small.copyWith(color: context.colors.ink),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.only(top: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
