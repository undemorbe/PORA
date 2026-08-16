import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/families/presentation/store/families_store.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';

class FamiliesCreateButton extends StatelessWidget {
  const FamiliesCreateButton({
    super.key,
    required this.familyTextController,
    required this.familiesStore,
  });

  final TextEditingController familyTextController;
  final FamiliesStore familiesStore;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      margin: const .symmetric(horizontal: 25),
      padding: const .only(top: 2),
      child: PoraOutlineButton(
        label: l.familiesCreate,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      context.l10n.familiesCreateDialog,
                      style: PoraText.heading.copyWith(
                        color: context.colors.ink,
                      ),
                    ),
                    const SizedBox(height: PoraSpacing.md),
                    TextField(
                      autocorrect: true,
                      controller: familyTextController,
                      onSubmitted: (value) async {
                        context.maybePop();
                        if (familyTextController.text.isNotEmpty) {
                          await familiesStore
                              .createFamily(name: value)
                              .whenComplete(() async {
                                await familiesStore.getFamilies();
                              });
                        }
                      },
                      maxLength: 24,
                    ),
                    Padding(
                      padding: const .all(15),
                      child: PoraPrimaryButton(
                        label: l.familiesCreate,
                        icon: PhosphorIcons.plusBold,
                        isLoading: false,
                        onPressed: () async {
                          context.maybePop();
                          if (familyTextController.text.isNotEmpty) {
                            await familiesStore
                                .createFamily(name: familyTextController.text)
                                .whenComplete(() async {
                                  await familiesStore.getFamilies();
                                });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
