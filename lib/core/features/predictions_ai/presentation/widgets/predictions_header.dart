import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_circle_icon_button.dart';

/// Хедер экрана «Пора»: заголовок/подзаголовок + кнопка инсайтов.
class PredictionsHeader extends StatelessWidget {
  const PredictionsHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onInsights,
  });

  final String title;
  final String subtitle;
  final VoidCallback onInsights;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: PoraText.title),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: PoraText.caption.copyWith(
                  color: context.colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        PoraCircleIconButton(
          icon: PhosphorIconsRegular.chartLineUp,
          iconColor: PoraColors.primary,
          onTap: onInsights,
        ),
      ],
    );
  }
}
