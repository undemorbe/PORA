import 'package:flutter/material.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// Сегментный переключатель периода статистики (7 / 30 / 90 дней).
class PeriodSwitch extends StatelessWidget {
  const PeriodSwitch({
    super.key,
    required this.periods,
    required this.value,
    required this.onChanged,
  });

  final List<int> periods;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: PoraRadii.button,
      ),
      child: Row(
        children: [
          for (final p in periods)
            Expanded(
              child: Semantics(
                button: true,
                selected: p == value,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p == value ? c.surface : Colors.transparent,
                      borderRadius: PoraRadii.md,
                      boxShadow: p == value ? PoraShadows.card : null,
                    ),
                    child: Text(
                      l.insightsPeriodDays(p),
                      style: PoraText.small.copyWith(
                        fontWeight: FontWeight.w700,
                        color: p == value
                            ? PoraColors.primaryDark
                            : c.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
