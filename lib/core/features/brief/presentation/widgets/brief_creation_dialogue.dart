import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product.dart';
import 'package:pora/core/features/brief/presentation/controller/brief_store.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';

class BriefCreationDialogue extends StatefulWidget {
  const BriefCreationDialogue({super.key, required this.briefStore});
  final BriefStore briefStore;

  @override
  State<BriefCreationDialogue> createState() => _BriefCreationDialogueState();
}

class _BriefCreationDialogueState extends State<BriefCreationDialogue> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emojiLeadingController = TextEditingController();
  bool _isAllergen = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(PoraSpacing.lg),
        child: Column(
          mainAxisSize: .min,
          children: [
            TextField(
              controller: nameController,
              maxLength: 15,
              decoration: InputDecoration(
                hintText: context.l10n.briefInputProduct,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              //! Add emoji keyboard type
              child: TextField(
                controller: emojiLeadingController,
                maxLength: 3,
                enabled: _isAllergen == false,
                //  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[emoji]'))],
                decoration: InputDecoration(
                  hintText: _isAllergen == false
                      ? context.l10n.briefInputEmoji
                      : "❌❌❌",
                ),
              ),
            ),
            PoraPrimaryButton(
              icon: PhosphorIcons.plus,
              onPressed: () {
                if (nameController.text.isEmpty) {
                  PoraSnackbar.show(
                    context,
                    message: context.l10n.briefInputProduct,
                    type: PoraSnackType.failure,
                  );
                  return;
                }
                final result = widget.briefStore.addToSelectedProducts(
                  BriefProductEntity(
                    title: nameController.text,
                    leading: emojiLeadingController.text.isEmpty
                        ? null
                        : emojiLeadingController.text,
                  ),
                );
                context.router.maybePop();
                if (!result) {
                  PoraSnackbar.show(
                    context,
                    message: context.l10n.briefAlreadyContains,
                    type: PoraSnackType.failure,
                  );
                }
              },
              label: context.l10n.save,
            ),
            Platform.isIOS
                ? ListTile(
                    title: Text(
                      context.l10n.allergen,
                      style: PoraText.itemTitle,
                    ),
                    leading: const Icon(PhosphorIconsRegular.trash),
                    contentPadding: .only(left: 16),
                    trailing: LiquidGlassToggle(
                      value: _isAllergen,
                      onChanged: (v) => _isAllergen = v,
                    ),
                  )
                : SwitchListTile(
                    title: Text(
                      context.l10n.allergen,
                      style: PoraText.itemTitle,
                    ),
                    secondary: const Icon(PhosphorIconsRegular.trash),
                    value: _isAllergen,
                    onChanged: (v) {
                      _isAllergen = v;
                      emojiLeadingController.text = _isAllergen ? "❌❌❌" : "";
                    },

                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PoraOutlineButton(
                onPressed: () {
                  context.router.maybePop();
                },
                label: context.l10n.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
