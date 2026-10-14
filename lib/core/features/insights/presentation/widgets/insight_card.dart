import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';

/// Общая поверхность блоков Insights: surface + hairline-обводка,
/// опциональный заголовок и trailing (легенда/подпись).
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(PoraSpacing.lg),
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.card,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: PoraText.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ?trailing,
              ],
            ),
            const SizedBox(height: PoraSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
