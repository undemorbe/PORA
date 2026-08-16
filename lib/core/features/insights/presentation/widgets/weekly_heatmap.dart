import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Тепловая карта активности за 4 недели — 4×7 ячеек.
/// Считает интенсивность по [logins]: `count(loginsInDay) / maxCountAcrossGrid`.
/// Weekdays подписаны в текущей локали (Пн/Вт/... или Mon/Tue/...).
class WeeklyHeatmap extends StatelessWidget {
  const WeeklyHeatmap({super.key, required this.logins});

  /// Все логины пользователя за последнюю неделю (или больше — grid ограничит).
  final List<DateTime> logins;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final grid = _buildGrid(logins);
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
            _title(locale),
            style: PoraText.itemTitle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PoraSpacing.md),
          _WeekdayLabels(labels: weekdayLabels),
          const SizedBox(height: 6),
          for (var w = 0; w < grid.length; w++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var d = 0; d < grid[w].length; d++)
                    Expanded(child: _Cell(intensity: grid[w][d])),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _less(locale),
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
                _more(locale),
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
  static List<List<double>> _buildGrid(List<DateTime> logins) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Понедельник текущей недели.
    final currentMonday =
        today.subtract(Duration(days: today.weekday - 1));

    // 4 недели: старейшая = currentMonday - 21 дней.
    final startDate = currentMonday.subtract(const Duration(days: 21));

    final counts = List.generate(4, (_) => List<int>.filled(7, 0));

    for (final t in logins) {
      final local = t.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final diff = day.difference(startDate).inDays;
      if (diff < 0 || diff >= 28) continue;
      final w = diff ~/ 7;
      final d = diff % 7;
      counts[w][d]++;
    }

    var max = 0;
    for (final row in counts) {
      for (final v in row) {
        if (v > max) max = v;
      }
    }
    if (max == 0) return List.generate(4, (_) => List<double>.filled(7, 0));

    return counts
        .map((row) => row.map((v) => v / max).toList())
        .toList();
  }

  static List<String> _weekdayLabels(String locale) {
    // Пн/Вт/Ср... в локали, короткие имена. intl `EEE` даёт «Mon»/«Пн».
    final base = DateTime(2024, 1, 1); // Понедельник
    final f = intl.DateFormat.E(locale);
    return List.generate(7, (i) => f.format(base.add(Duration(days: i))));
  }

  static String _title(String locale) => locale.startsWith('ru')
      ? 'Активность за 4 недели'
      : 'Activity · last 4 weeks';

  static String _less(String locale) =>
      locale.startsWith('ru') ? 'меньше' : 'less';

  static String _more(String locale) =>
      locale.startsWith('ru') ? 'больше' : 'more';
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels({required this.labels});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in labels)
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
