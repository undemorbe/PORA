import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';

/// Крошечный тег «demo» рядом с моковыми числами. Честнее чем
/// показывать выдуманные метрики как реальные — пользователь видит,
/// что цифры условные до подключения бэка предсказаний.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key, this.text = 'demo'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Text(
        text,
        style: PoraText.micro.copyWith(
          color: c.textSubtle,
          fontSize: 9,
          letterSpacing: 0.4,
          height: 1,
        ),
      ),
    );
  }
}
