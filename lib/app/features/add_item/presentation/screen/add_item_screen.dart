import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/add_item/presentation/widgets/quantity_stepper.dart';
import 'package:pora/app/features/item_detail/domain/usecase/add_item.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';
import 'package:pora/app/internal/widgets/pora_toggle.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Добавить продукт вручную в конкретный список.
@RoutePage()
class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, required this.lid});

  final String lid;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameController = TextEditingController();
  final _customUnitController = TextEditingController();
  final _customSectionController = TextEditingController();

  int _qty = 1;
  int _priority = 1;
  bool _urgent = false;
  bool _remind = false;
  int _remindDays = 1;
  bool _busy = false;

  String _unit = 'шт';
  String _section = 'Разное';

  static const _units = ['шт', 'г', 'кг', 'мл', 'л', 'уп'];
  static const _sections = <(String, String)>[
    ('🥦', 'Овощи и фрукты'),
    ('🥛', 'Молочное'),
    ('🍝', 'Бакалея'),
    ('🧃', 'Напитки'),
    ('🍞', 'Хлеб'),
    ('🧀', 'Разное'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _customUnitController.dispose();
    _customSectionController.dispose();
    super.dispose();
  }

  bool get _hasCustomUnit => !_units.contains(_unit);
  bool get _hasCustomSection => !_sections.any((s) => s.$2 == _section);

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _busy) return;
    setState(() => _busy = true);
    final res = await GetIt.I<AddItemUseCase>().call(
      listId: widget.lid,
      name: name,
      section: _section,
      quantity: _qty,
      unit: _unit,
      priority: _priority,
      urgent: _urgent,
      remindEveryDays: _remind ? _remindDays : null,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (res.isRight) {
      Navigator.of(context).pop(true);
    } else {
      PoraSnackbar.show(context, message: res.left.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: l.addProduct, onClose: () => context.router.maybePop()),
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
                    style: PoraText.bodyLarge.copyWith(fontSize: 18),
                    decoration: InputDecoration(hintText: l.productName),
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  SectionLabel(l.addItemQuantity),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityStepper(
                        value: _qty,
                        onDecrement: () =>
                            setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                        onIncrement: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.lg),

                  SectionLabel(l.unit),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final u in _units)
                        PoraChip(
                          label: u,
                          dense: true,
                          selected: u == _unit,
                          onTap: () => setState(() => _unit = u),
                        ),
                      PoraChip(
                        label: _hasCustomUnit ? _unit : l.customValue,
                        leading: '✏️',
                        dense: true,
                        selected: _hasCustomUnit,
                        onTap: () => _promptCustom(
                          controller: _customUnitController,
                          hint: l.unit,
                          onSubmit: (v) => setState(() => _unit = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  SectionLabel(l.section),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final (emoji, name) in _sections)
                        PoraChip(
                          label: name,
                          leading: emoji,
                          dense: true,
                          selected: name == _section,
                          onTap: () => setState(() => _section = name),
                        ),
                      PoraChip(
                        label: _hasCustomSection ? _section : l.customValue,
                        leading: '✏️',
                        dense: true,
                        selected: _hasCustomSection,
                        onTap: () => _promptCustom(
                          controller: _customSectionController,
                          hint: l.section,
                          onSubmit: (v) => setState(() => _section = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  SectionLabel(l.priorityLabel),
                  Wrap(
                    spacing: 9,
                    children: [
                      for (final entry in [
                        (0, l.priorityLow),
                        (1, l.priorityMed),
                        (2, l.priorityHigh),
                      ])
                        PoraChip(
                          label: entry.$2,
                          dense: true,
                          selected: entry.$1 == _priority,
                          onTap: () => setState(() => _priority = entry.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  PoraRowsCard(
                    children: [
                      PoraSettingRow(
                        icon: PhosphorIconsRegular.clock,
                        label: l.urgent,
                        trailing: PoraToggle(
                          value: _urgent,
                          onChanged: (v) => setState(() => _urgent = v),
                        ),
                      ),
                      PoraSettingRow(
                        icon: PhosphorIconsRegular.arrowsClockwise,
                        label: l.remindEvery,
                        subtitle: _remind
                            ? '$_remindDays ${l.days}'
                            : null,
                        trailing: PoraToggle(
                          value: _remind,
                          onChanged: (v) => setState(() => _remind = v),
                        ),
                      ),
                      if (_remind)
                        _RemindDaysCounter(
                          value: _remindDays,
                          onChanged: (v) => setState(() => _remindDays = v),
                        ),
                    ],
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
              child: PoraPrimaryButton(
                label: l.save,
                isLoading: _busy,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptCustom({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onSubmit,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(ctx.l10n.save),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) onSubmit(result);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PoraSpacing.screen,
        PoraSpacing.sm,
        PoraSpacing.screen,
        0,
      ),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: PhosphorIcon(
                    PhosphorIconsRegular.arrowLeft,
                    size: 22,
                    color: context.colors.ink,
                  ),
                ),
              ),
            ),
            Text(title, style: PoraText.navTitle),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 22,
                    color: context.colors.textSubtle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemindDaysCounter extends StatelessWidget {
  const _RemindDaysCounter({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PoraSpacing.lg,
        0,
        PoraSpacing.lg,
        PoraSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.remindEvery, style: PoraText.body),
          Row(
            children: [
              _Btn(
                icon: PhosphorIconsBold.minus,
                enabled: value > 1,
                onTap: () => onChanged(value - 1),
              ),
              const SizedBox(width: PoraSpacing.md),
              SizedBox(
                width: 42,
                child: Text(
                  '$value ${context.l10n.days}',
                  textAlign: TextAlign.center,
                  style: PoraText.bodyLarge,
                ),
              ),
              const SizedBox(width: PoraSpacing.md),
              _Btn(
                icon: PhosphorIconsBold.plus,
                enabled: value < 7,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: PoraRadii.sm,
          border: Border.all(color: context.colors.border),
        ),
        child: PhosphorIcon(
          icon,
          size: 15,
          color: enabled ? PoraColors.primaryDark : context.colors.textMuted,
        ),
      ),
    );
  }
}
