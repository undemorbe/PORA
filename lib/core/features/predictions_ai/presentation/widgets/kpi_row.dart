import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Компактный ряд 3-х KPI-плиток. Замена stat_card из insights под контекст
/// главного экрана (иконка + число + подпись).
class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.items});

  final List<KpiItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _Tile(item: items[i])),
        ],
      ],
    );
  }
}

class KpiItem {
  const KpiItem({
    required this.icon,
    required this.number,
    required this.label,
  });
  final IconData icon;
  final String number;
  final String label;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});
  final KpiItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.card,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 16, color: PoraColors.primary),
          const SizedBox(height: 6),
          Text(
            item.number,
            style: PoraText.title.copyWith(
              fontSize: 20,
              color: c.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: PoraText.small.copyWith(color: c.textSubtle, height: 1.25),
          ),
        ],
      ),
    );
  }
}
