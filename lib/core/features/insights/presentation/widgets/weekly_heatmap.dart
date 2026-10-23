import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// Тепловая карта активности за 4 недели — 4×7 ячеек.
/// Интенсивность: `activity[day] / max(activity)`; сегодняшняя ячейка
/// обведена. Weekdays подписаны в текущей локали (Пн/Вт/... или Mon/Tue/...).
class WeeklyHeatmap extends StatelessWidget {
  const WeeklyHeatmap({super.key, required this.activity, this.now});

  /// Полночь локального дня → количество событий (логины + действия).
  final Map<DateTime, int> activity;

  /// Подмена «сегодня» для тестов/golden'ов.
  final DateTime? now;

  static const double _gap = 4;
  static const double _maxCell = 34;

  /// Цвет ступени интенсивности (общий для ячеек и легенды). Пустой день —
  /// самая светлая ступень, а не цвет карточки: сетка 4×7 видна всегда.
  /// Полупрозрачный primary поверх `surface` читается в обеих темах.
  @visibleForTesting
  static Color levelColor(double intensity) {
    final v = intensity.clamp(0.0, 1.0);
    if (v < 0.05) return PoraColors.primary.withValues(alpha: 0.12);
    return Color.lerp(
      PoraColors.primary.withValues(alpha: 0.3),
      PoraColors.primary,
      v,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final today = now ?? DateTime.now();
    final grid = _buildGrid(activity, today);
    final todayIndex = 21 + today.weekday - 1;
    final weekdayLabels = _weekdayLabels(locale);
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
            l.insightsHeatmapTitle,
            style: PoraText.itemTitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PoraSpacing.md),
          // Квадратные ячейки одного размера: ширина колонки, но не больше
          // [_maxCell] — на широком экране сетка не раздувается.
          LayoutBuilder(
            builder: (context, constraints) {
              final cell = math.min(
                (constraints.maxWidth - _gap * 6) / 7,
                _maxCell,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WeekdayLabels(labels: weekdayLabels, cell: cell),
                  const SizedBox(height: 6),
                  for (var w = 0; w < grid.length; w++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: w == grid.length - 1 ? 0 : _gap,
                      ),
                      child: Row(
                        children: [
                          for (var d = 0; d < grid[w].length; d++) ...[
                            if (d > 0) const SizedBox(width: _gap),
                            _Cell(
                              key: ValueKey('heatmap-cell-${w * 7 + d}'),
                              size: cell,
                              intensity: grid[w][d],
                              isToday: w * 7 + d == todayIndex,
                              isFuture: w * 7 + d > todayIndex,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: PoraSpacing.md),
          Row(
            children: [
              Text(
                l.insightsLess,
                style: PoraText.micro.copyWith(color: c.textSubtle),
              ),
              const SizedBox(width: 6),
              // Первая ступень легенды = пустой день.
              for (final v in const [0.0, 0.35, 0.7, 1.0])
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: _LegendDot(intensity: v),
                ),
              const SizedBox(width: 3),
              Text(
                l.insightsMore,
                style: PoraText.micro.copyWith(color: c.textSubtle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Формирует 4×7 сетку [0..1] интенсивности.
  /// Ряд 0 — старейшая неделя, ряд 3 — текущая. Столбец 0 = понедельник.
  static List<List<double>> _buildGrid(
    Map<DateTime, int> activity,
    DateTime now,
  ) {
    // Понедельник три недели назад; сдвиг календарный (DST-safe).
    final start = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1) - 21,
    );
    final counts = List.generate(4, (_) => List<int>.filled(7, 0));
    var max = 0;
    for (var i = 0; i < 28; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      final v = activity[day] ?? 0;
      counts[i ~/ 7][i % 7] = v;
      if (v > max) max = v;
    }
    if (max == 0) return List.generate(4, (_) => List<double>.filled(7, 0));
    return counts.map((row) => row.map((v) => v / max).toList()).toList();
  }

  static List<String> _weekdayLabels(String locale) {
    // Пн/Вт/Ср... в локали, короткие имена. intl `EEE` даёт «Mon»/«Пн».
    final base = DateTime(2024, 1, 1); // Понедельник
    final f = intl.DateFormat.E(locale);
    return List.generate(7, (i) => f.format(base.add(Duration(days: i))));
  }
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels({required this.labels, required this.cell});
  final List<String> labels;
  final double cell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: WeeklyHeatmap._gap),
          SizedBox(
            width: cell,
            child: Text(
              labels[i],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: PoraText.micro.copyWith(color: context.colors.textSubtle),
            ),
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.size,
    required this.intensity,
    this.isToday = false,
    this.isFuture = false,
  });
  final double size;
  final double intensity;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final empty = WeeklyHeatmap.levelColor(0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Будущие дни — только контур пустой ступени.
        color: isFuture
            ? Colors.transparent
            : WeeklyHeatmap.levelColor(intensity),
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: PoraColors.primaryDark, width: 1.5)
            : isFuture
            ? Border.all(color: empty)
            : null,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.intensity});
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: WeeklyHeatmap.levelColor(intensity),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
