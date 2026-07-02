import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/dashed_circle.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';

/// Кластер аватаров при приглашении: участник + место под второго.
class InviteAvatars extends StatelessWidget {
  const InviteAvatars({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PoraAvatar(
          initial: 'Б',
          color: PoraColors.primary,
          size: PoraSizes.avatarXl,
        ),
        const SizedBox(width: 14),
        const Text('🤍', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        DashedCircle(
          size: PoraSizes.avatarXl,
          color: PoraColors.primary,
          child: const PhosphorIcon(
            PhosphorIconsBold.plus,
            size: 28,
            color: PoraColors.primary,
          ),
        ),
      ],
    );
  }
}
