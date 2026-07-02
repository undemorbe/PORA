import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';

/// Аватар + имя участника, добавившего товар (трейлинг строки «Добавил(а)»).
class AddedBy extends StatelessWidget {
  const AddedBy({
    super.key,
    this.initial = 'Б',
    this.color = PoraColors.primary,
    this.name = 'Борис',
  });

  final String initial;
  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PoraAvatar(initial: initial, color: color),
        const SizedBox(width: PoraSpacing.sm),
        Text(name, style: PoraText.itemTitle),
      ],
    );
  }
}
