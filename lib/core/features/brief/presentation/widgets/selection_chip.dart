import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product.dart';
import 'package:pora/core/features/brief/presentation/controller/brief_store.dart';
import 'package:pora/core/internal/widgets/deletion_dialogue.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';

class PoraSelectionChip extends StatefulWidget {
  const PoraSelectionChip({
    super.key,
    required this.briefStore,
    required this.briefProductEntity,
  });
  final BriefProductEntity briefProductEntity;
  final BriefStore briefStore;
  @override
  State<PoraSelectionChip> createState() => _PoraSelectionChipState();
}

class _PoraSelectionChipState extends State<PoraSelectionChip> {
  late bool selected;

  @override
  void initState() {
    super.initState();
    selected = widget.briefStore.isContainsProduct(widget.briefProductEntity);
  }

  void onChipTap() {
    selected = !selected;
    if (selected) {
      widget.briefStore.addToSelectedProducts(widget.briefProductEntity);
      setState(() {});
    } else {
      widget.briefStore.removeFromSelected(widget.briefProductEntity);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChipTap,
      onLongPress: () async {
        await showAdaptiveDialog(
          context: context,
          builder: (context) => DeletionDialogue(
            onDelete: () {
              widget.briefStore.deleteProduct(widget.briefProductEntity);
            },
          ),
        );
      },
      child: Observer(
        builder: (_) {
          final selectedPr = widget.briefStore.selectedProducts;
          selected = selectedPr.contains(widget.briefProductEntity);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? PoraColors.primaryTint : context.colors.surface,
              borderRadius: PoraRadii.pill,
              border: Border.all(
                color: selected ? PoraColors.primary : context.colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.briefProductEntity.leading != null) ...[
                  Text(
                    widget.briefProductEntity.leading!,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.briefProductEntity.title,
                  style: TextStyle(
                    fontFamily: kPoraFontFamily,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? PoraColors.primaryDark
                        : context.colors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
