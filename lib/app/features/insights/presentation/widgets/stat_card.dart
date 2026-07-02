import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

/// Мини-карточка статистики (число + подпись).
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PoraCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: PoraText.title.copyWith(
              fontSize: 22,
              color: PoraColors.primaryDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: PoraText.small.copyWith(height: 1.3)),
        ],
      ),
    );
  }
}
