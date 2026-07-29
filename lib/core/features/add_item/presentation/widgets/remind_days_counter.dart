import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Counter −/+ для remindEveryDays (1..7).
class RemindDaysCounter extends StatelessWidget {
  const RemindDaysCounter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PoraSpacing.lg,
        0,
        PoraSpacing.lg,
        PoraSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.remindEvery, style: PoraText.body),
          Row(
            children: [
              _Btn(
                icon: PhosphorIconsBold.minus,
                enabled: value > AddItemDefaults.remindDaysMin,
                onTap: () => onChanged(value - 1),
              ),
              const SizedBox(width: PoraSpacing.md),
              SizedBox(
                width: 46,
                child: Text(
                  '$value ${context.l10n.days}',
                  textAlign: TextAlign.center,
                  style: PoraText.bodyLarge,
                ),
              ),
              const SizedBox(width: PoraSpacing.md),
              _Btn(
                icon: PhosphorIconsBold.plus,
                enabled: value < AddItemDefaults.remindDaysMax,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: PoraRadii.sm,
          border: Border.all(color: c.border),
        ),
        child: PhosphorIcon(
          icon,
          size: 15,
          color: enabled ? PoraColors.primaryDark : c.textMuted,
        ),
      ),
    );
  }
}
