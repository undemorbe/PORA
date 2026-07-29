import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/dashed_circle.dart';
import 'package:pora/core/internal/widgets/pora_avatar.dart';

/// Кластер аватаров при приглашении: участник + место под второго.
class InviteAvatars extends StatelessWidget {
  const InviteAvatars({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PoraAvatar(
          initial: 'you',
          color: PoraColors.primary,
          size: PoraSizes.avatarXl,
        ),
        SizedBox(width: 14),
        Text('🤍', style: TextStyle(fontSize: 24)),
        SizedBox(width: 14),
        DashedCircle(
          size: PoraSizes.avatarXl,
          color: PoraColors.primary,
          child: PhosphorIcon(
            PhosphorIconsBold.questionMark,
            size: 28,
            color: PoraColors.primary,
          ),
        ),
      ],
    );
  }
}
