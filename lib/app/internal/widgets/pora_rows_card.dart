import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

/// Карточка со строками, разделёнными тонкими линиями (настройки, детали товара).
class PoraRowsCard extends StatelessWidget {
  const PoraRowsCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: PoraSpacing.xs),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        divided.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: PoraSpacing.lg,
            endIndent: PoraSpacing.lg,
            color: Theme.of(context).dividerColor,
          ),
        );
      }
      divided.add(children[i]);
    }
    return PoraCard(
      padding: padding,
      child: Column(children: divided),
    );
  }
}
