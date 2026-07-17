import 'package:flutter/material.dart';
import 'package:pora/app/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/app/features/add_item/presentation/widgets/custom_value_dialog.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';

/// Chip-wrap sections + «Своё…».
class SectionSelector extends StatelessWidget {
  const SectionSelector({
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
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final (emoji, name) in AddItemDefaults.sections)
          PoraChip(
            label: name,
            leading: emoji,
            dense: true,
            selected: name == value,
            onTap: () => onChanged(name),
          ),
        PoraChip(
          label: isCustom ? value : context.l10n.customValue,
          leading: '✏️',
          dense: true,
          selected: isCustom,
          onTap: () async {
            final v = await showCustomValueDialog(
              context,
              hint: context.l10n.section,
              initial: isCustom ? value : '',
            );
            if (v != null && v.isNotEmpty) onChanged(v);
          },
        ),
      ],
    );
  }
}
