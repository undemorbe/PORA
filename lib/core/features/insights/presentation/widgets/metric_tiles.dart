import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

class MetricTile {
  const MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
}

/// Сетка компактных метрик (иконка + число + подпись), 3 в ряд на телефоне.
class MetricTiles extends StatelessWidget {
  const MetricTiles({super.key, required this.tiles});

  final List<MetricTile> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = PoraSpacing.sm;
        final perRow = constraints.maxWidth > 520 ? 5 : 3;
        final width = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles)
              SizedBox(
                width: width,
                child: _Tile(tile: t),
              ),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile});
  final MetricTile tile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.card,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tile.icon, size: 18, color: PoraColors.primary),
          const SizedBox(height: 6),
          Text(
            tile.value,
            style: PoraText.heading.copyWith(
              fontSize: 18,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            tile.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PoraText.micro.copyWith(color: c.textMuted, height: 1.25),
          ),
        ],
      ),
    );
  }
}
