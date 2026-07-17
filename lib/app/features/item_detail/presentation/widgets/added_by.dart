import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';

/// Аватар + имя добавившего.
class AddedBy extends StatelessWidget {
  const AddedBy({super.key, required this.member});

  final MemberEntity member;

  @override
  Widget build(BuildContext context) {
    final initial = member.name.isEmpty ? '?' : member.name[0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PoraAvatar(
          initial: initial,
          color: memberColor(member, 0),
          imageUrl: member.imageUrl,
        ),
        const SizedBox(width: PoraSpacing.sm),
        Text(member.name, style: PoraText.itemTitle),
      ],
    );
  }
}
