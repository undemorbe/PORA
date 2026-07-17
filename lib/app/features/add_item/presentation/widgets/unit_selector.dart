import 'package:flutter/material.dart';
import 'package:pora/app/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/app/features/add_item/presentation/widgets/custom_value_dialog.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';

/// Chip-ряд из predefined units + «Своё…» chip.
class UnitSelector extends StatelessWidget {
  const UnitSelector({
    super.key,
    required this.value,
    required this.isCustom,
    required this.onChanged,
  });

  final String value;
  final bool isCustom;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: PoraSpacing.sm,
      runSpacing: PoraSpacing.sm,
      children: [
        for (final u in AddItemDefaults.units)
          PoraChip(
            label: u,
            dense: true,
            selected: u == value,
            onTap: () => onChanged(u),
          ),
        PoraChip(
          label: isCustom ? value : context.l10n.customValue,
          leading: '✏️',
          dense: true,
          selected: isCustom,
          onTap: () async {
            final v = await showCustomValueDialog(
              context,
              hint: context.l10n.unit,
              initial: isCustom ? value : '',
            );
            if (v != null && v.isNotEmpty) onChanged(v);
          },
        ),
      ],
    );
  }
}
