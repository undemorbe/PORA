import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Карточка кода приглашения с кнопкой «Копировать».
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({super.key, required this.code, this.onCopy});

  final String code;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return PoraCard(
      padding: const EdgeInsets.fromLTRB(18, 16, PoraSpacing.lg, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Код приглашения', style: PoraText.small),
                const SizedBox(height: PoraSpacing.xs),
                Text(code, style: PoraText.code),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: const PoraPill(label: 'Копировать'),
          ),
        ],
      ),
    );
  }
}
