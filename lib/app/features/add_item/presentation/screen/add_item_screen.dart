import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/add_item/presentation/store/add_item_store.dart';
import 'package:pora/app/features/add_item/presentation/widgets/add_item_header.dart';
import 'package:pora/app/features/add_item/presentation/widgets/priority_selector.dart';
import 'package:pora/app/features/add_item/presentation/widgets/quantity_stepper.dart';
import 'package:pora/app/features/add_item/presentation/widgets/remind_days_counter.dart';
import 'package:pora/app/features/add_item/presentation/widgets/section_selector.dart';
import 'package:pora/app/features/add_item/presentation/widgets/unit_selector.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';
import 'package:pora/app/internal/widgets/pora_toggle.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Добавление продукта в конкретный список.
@RoutePage()
class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, required this.lid});

  final String lid;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late final AddItemStore store = AddItemStore(lid: widget.lid);
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await store.submit();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else if (store.errorMessage != null) {
      PoraSnackbar.show(context, message: store.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AddItemHeader(
              title: l.addProduct,
              onBack: () => context.router.maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PoraSpacing.screen,
                  PoraSpacing.lg,
                  PoraSpacing.screen,
                  PoraSpacing.lg,
                ),
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: store.setName,
                    style: PoraText.bodyLarge.copyWith(fontSize: 18),
                    decoration: InputDecoration(hintText: l.productName),
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  SectionLabel(l.addItemQuantity),
                  Observer(
                    builder: (_) => QuantityStepper(
                      value: store.quantity,
                      onDecrement: store.decrement,
                      onIncrement: store.increment,
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.lg),

                  SectionLabel(l.unit),
                  Observer(
                    builder: (_) => UnitSelector(
                      value: store.unit,
                      isCustom: store.hasCustomUnit,
                      onChanged: store.setUnit,
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  SectionLabel(l.section),
                  Observer(
                    builder: (_) => SectionSelector(
                      value: store.section,
                      isCustom: store.hasCustomSection,
                      onChanged: store.setSection,
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  SectionLabel(l.priorityLabel),
                  Observer(
                    builder: (_) => PrioritySelector(
                      value: store.priority,
                      onChanged: store.setPriority,
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  Observer(
                    builder: (_) => PoraRowsCard(
                      children: [
                        PoraSettingRow(
                          icon: PhosphorIconsRegular.clock,
                          label: l.urgent,
                          trailing: PoraToggle(
                            value: store.urgent,
                            onChanged: store.toggleUrgent,
                          ),
                        ),
                        PoraSettingRow(
                          icon: PhosphorIconsRegular.arrowsClockwise,
                          label: l.remindEvery,
                          subtitle: store.remind
                              ? '${store.remindDays} ${l.days}'
                              : null,
                          trailing: PoraToggle(
                            value: store.remind,
                            onChanged: store.toggleRemind,
                          ),
                        ),
                        if (store.remind)
                          RemindDaysCounter(
                            value: store.remindDays,
                            onChanged: store.setRemindDays,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              child: Observer(
                builder: (_) => PoraPrimaryButton(
                  label: l.save,
                  isLoading: store.busy,
                  onPressed: store.canSubmit ? _submit : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
