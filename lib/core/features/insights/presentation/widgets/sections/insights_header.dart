import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';

/// Заголовок экрана Insights с кнопкой «назад».
class InsightsHeader extends StatelessWidget {
  const InsightsHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: MaterialLocalizations.of(context).backButtonTooltip,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Icon(PhosphorIconsRegular.caretLeft, size: 26),
            ),
          ),
        ),
        const SizedBox(width: PoraSpacing.md),
        Text(title, style: PoraText.title),
      ],
    );
  }
}
