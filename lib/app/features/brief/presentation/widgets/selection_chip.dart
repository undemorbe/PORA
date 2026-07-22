import 'package:flutter/material.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product.dart';
import 'package:pora/app/features/brief/presentation/controller/brief_store.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

class PoraSelectionChip extends StatefulWidget {
  const PoraSelectionChip({
    super.key,
    required this.briefStore,
    required this.briefProductEntity,
    this.leadingEmoji,
  });
  final BriefProductEntity briefProductEntity;
  final String? leadingEmoji;
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
      child: Container(
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
            if (widget.leadingEmoji != null) ...[
              Text(widget.leadingEmoji!, style: TextStyle(fontSize: 15)),
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
      ),
    );
  }
}
