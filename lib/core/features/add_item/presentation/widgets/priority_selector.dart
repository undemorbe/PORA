import 'package:flutter/material.dart';
import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/features/add_item/presentation/item_labels.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/widgets/pora_chip.dart';

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = <(int, String)>[
      for (final p in AddItemDefaults.priorities) (p, l.priorityName(p)),
    ];
    return Wrap(
      spacing: PoraSpacing.sm,
      children: [
        for (final e in entries)
          PoraChip(
            label: e.$2,
            dense: true,
            selected: e.$1 == value,
            onTap: () => onChanged(e.$1),
          ),
      ],
    );
  }
}
