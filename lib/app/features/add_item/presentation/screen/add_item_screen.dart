import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/add_item/presentation/widgets/quantity_stepper.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/pora_toggle.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Добавить продукт вручную: поле, количество, раздел, тумблеры.
@RoutePage()
class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  int _qty = 2;
  String _unit = 'шт';
  String _section = 'Овощи и фрукты';
  bool _urgent = false;
  bool _remind = true;

  static const _units = ['шт', 'г', 'кг', 'л'];
  static const _sections = <(String, String)>[
    ('🥦', 'Овощи и фрукты'),
    ('🥛', 'Молочное'),
    ('🍝', 'Бакалея'),
    ('🧃', 'Напитки'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                PoraSpacing.sm,
                PoraSpacing.screen,
                0,
              ),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('Добавить продукт', style: PoraText.navTitle),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.router.maybePop(),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.x,
                          size: 22,
                          color: PoraColors.textSubtle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                  TextFormField(
                    initialValue: 'Авокадо',
                    style: PoraText.bodyLarge.copyWith(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Название продукта',
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.xl),

                  const SectionLabel('Количество'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityStepper(
                        value: _qty,
                        onDecrement: () =>
                            setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                        onIncrement: () => setState(() => _qty++),
                      ),
                      Wrap(
                        spacing: PoraSpacing.sm,
                        children: [
                          for (final u in _units)
                            PoraChip(
                              label: u,
                              dense: true,
                              selected: u == _unit,
                              onTap: () => setState(() => _unit = u),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.xxl),

                  const SectionLabel('Раздел'),
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
                    ],
                  ),
                  const SizedBox(height: PoraSpacing.xxl),

                  PoraRowsCard(
                    children: [
                      PoraSettingRow(
                        icon: PhosphorIconsRegular.clock,
                        label: 'Срочно',
                        subtitle: 'Нужно купить сегодня',
                        trailing: PoraToggle(
                          value: _urgent,
                          onChanged: (v) => setState(() => _urgent = v),
                        ),
                      ),
                      PoraSettingRow(
                        icon: PhosphorIconsRegular.arrowsClockwise,
                        label: 'Напоминать регулярно',
                        subtitle: 'Каждые 7 дней',
                        trailing: PoraToggle(
                          value: _remind,
                          onChanged: (v) => setState(() => _remind = v),
                        ),
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
                label: 'Добавить в список',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
