import 'package:flutter/material.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';

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
      (0, l.priorityLow),
      (1, l.priorityMed),
      (2, l.priorityHigh),
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
