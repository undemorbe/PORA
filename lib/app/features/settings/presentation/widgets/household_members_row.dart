import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Строка участников хозяйства с перекрытыми аватарами и кнопкой «Пригласить».
class HouseholdMembersRow extends StatelessWidget {
  const HouseholdMembersRow({super.key});

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 32,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: PoraAvatar(
                    initial: 'Б',
                    color: PoraColors.primary,
                    size: 32,
                    ring: ring,
                  ),
                ),
                Positioned(
                  left: 22,
                  child: PoraAvatar(
                    initial: 'А',
                    color: PoraColors.sage,
                    size: 32,
                    ring: ring,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(child: Text('Борис и Анна', style: PoraText.itemTitle)),
          const PoraPill(label: 'Пригласить'),
        ],
      ),
    );
  }
}
