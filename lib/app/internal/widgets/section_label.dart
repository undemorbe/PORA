import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';

/// Заголовок-разделитель секции («МОЛОЧНОЕ», «РЕЗУЛЬТАТЫ» …).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: PoraSpacing.xs,
        bottom: PoraSpacing.sm,
      ),
      child: Text(text.toUpperCase(), style: PoraText.overline),
    );
  }
}
