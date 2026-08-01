import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Тепловая карта активности покупок: 4 недели × 7 дней.
/// [data] — 4 массива по 7 значений [0..1]. Пример:
/// `[[0.1, 0.6, ...], ...]` неделя-старейшая → неделя-текущая.
class WeeklyHeatmap extends StatelessWidget {
  const WeeklyHeatmap({super.key, required this.data});
  final List<List<double>> data;

  static const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.card,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Активность за 4 недели',
            style: PoraText.itemTitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PoraSpacing.md),
          _WeekdayLabels(),
          const SizedBox(height: 6),
          for (var w = 0; w < data.length; w++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var d = 0; d < data[w].length; d++)
                    Expanded(child: _Cell(intensity: data[w][d])),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'меньше',
                style: PoraText.micro.copyWith(color: c.textSubtle),
              ),
              const SizedBox(width: 6),
              for (final v in const [0.15, 0.4, 0.7, 1.0])
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: _LegendDot(intensity: v),
                ),
              const SizedBox(width: 3),
              Text(
                'больше',
                style: PoraText.micro.copyWith(color: c.textSubtle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in WeeklyHeatmap._weekdays)
          Expanded(
            child: Center(
              child: Text(
                d,
                style: PoraText.micro.copyWith(
                  color: context.colors.textSubtle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.intensity});
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = intensity.clamp(0.0, 1.0);
    final color = v < 0.05
        ? c.surfaceAlt
        : Color.lerp(
            PoraColors.primary.withValues(alpha: 0.15),
            PoraColors.primary,
            v,
          )!;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.intensity});
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      PoraColors.primary.withValues(alpha: 0.2),
      PoraColors.primary,
      intensity,
    )!;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
