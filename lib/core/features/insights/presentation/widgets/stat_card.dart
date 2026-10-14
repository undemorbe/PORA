import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_card.dart';

/// Мини-карточка статистики: число + подпись, опционально тренд к прошлому
/// периоду ([delta], %) и мелкая подсказка ([hint]).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.number,
    required this.label,
    this.delta,
    this.hint,
  });

  final String number;
  final String label;
  final int? delta;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final d = delta;
    return PoraCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  number,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PoraText.title.copyWith(
                    fontSize: 22,
                    color: PoraColors.primaryDark,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (d != null && d != 0) ...[
                const SizedBox(width: 6),
                _Delta(value: d),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(label, style: PoraText.small.copyWith(height: 1.3)),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: PoraText.micro.copyWith(color: context.colors.textSubtle),
            ),
          ],
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final up = value > 0;
    final color = up ? PoraColors.success : PoraColors.danger;
    final shown = value.abs() > 999 ? '999+' : '${value.abs()}';
    return Text(
      '${up ? '↑' : '↓'}$shown%',
      style: PoraText.micro.copyWith(color: color, fontWeight: FontWeight.w800),
    );
  }
}
