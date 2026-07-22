import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product.dart';
import 'package:pora/app/features/brief/presentation/controller/brief_store.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';

class BriefCreationDialogue extends StatefulWidget {
  const BriefCreationDialogue({super.key, required this.briefStore});
  final BriefStore briefStore;

  @override
  State<BriefCreationDialogue> createState() => _BriefCreationDialogueState();
}

class _BriefCreationDialogueState extends State<BriefCreationDialogue> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emojiLeadingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(PoraSpacing.lg),
        child: Column(
          mainAxisSize: .min,
          children: [
            TextField(controller: nameController,maxLength: 15,decoration: InputDecoration(
              hintText: context.l10n.briefInputProduct
            ),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              //! Add emoji keyboard type
              child: TextField(controller: emojiLeadingController,maxLength: 3,
              //  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[emoji]'))],
              decoration: InputDecoration(
                hintText: context.l10n.briefInputEmoji,
              ),
                ),
            ),
            PoraOutlineButton(
              onPressed: () {
                widget.briefStore.addToSelectedProducts(
                  BriefProductEntity(
                    title: nameController.text,
                    leading: emojiLeadingController.text.isEmpty
                        ? null
                        : emojiLeadingController.text,
                  ),
                );
              },
              label: context.l10n.save,
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
