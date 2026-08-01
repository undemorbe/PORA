import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Продукт-«чемпион» месяца: эмодзи + название + сколько раз куплено.
class ChampionCard extends StatelessWidget {
  const ChampionCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.count,
  });

  final String emoji;
  final String name;
  final int count;

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
          Row(
            children: [
              const Icon(
                PhosphorIconsFill.trophy,
                size: 16,
                color: PoraColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'ЧЕМПИОН МЕСЯЦА',
                style: PoraText.small.copyWith(
                  color: PoraColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: PoraSpacing.md),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: PoraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: PoraText.title.copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(
                      'куплено $count раз за месяц',
                      style: PoraText.small.copyWith(color: c.textSubtle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
