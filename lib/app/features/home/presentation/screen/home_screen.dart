import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/home/domain/entity/list_item.dart';
import 'package:pora/app/features/home/presentation/widgets/add_list_button.dart';
import 'package:pora/app/features/home/presentation/widgets/list_header.dart';
import 'package:pora/app/features/home/presentation/widgets/section_group.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_bottom_nav.dart';

/// Главный экран — общий список покупок семьи («Наш список»).
///
/// Пока с демо-данными; при интеграции заменяется на MobX-стор
/// (presentation/store) + данные из бэкенда/WebSocket.
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Демо-данные (позже — из стора).
  static const _sections = <ListSection>[
    ListSection(
      title: 'Молочное',
      items: [
        ListItem(name: 'Молоко', qty: '2 л', addedBy: 'Б', urgent: true),
        ListItem(name: 'Сыр пармезан', qty: '200 г', addedBy: 'А'),
        ListItem(name: 'Йогурт', qty: '4 шт', addedBy: 'Б', checked: true),
      ],
    ),
    ListSection(
      title: 'Овощи и фрукты',
      items: [
        ListItem(name: 'Бананы', addedBy: 'А'),
        ListItem(name: 'Помидоры', qty: '1 кг', addedBy: 'Б'),
      ],
    ),
    ListSection(
      title: 'Бакалея',
      items: [
        ListItem(name: 'Паста спагетти', qty: '500 г', addedBy: 'Б'),
        ListItem(name: 'Кофе зерновой', addedBy: 'А', urgent: true),
      ],
    ),
  ];

  static Color _colorOf(String initial) =>
      initial == 'А' ? PoraColors.sage : PoraColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const AddListButton(),
      bottomNavigationBar: const PoraBottomNav(current: PoraTab.list),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            PoraSpacing.sm,
            PoraSpacing.screen,
            100, // место под плавающую кнопку
          ),
          children: [
            const ListHeader(
              title: 'Наш список',
              subtitle: '2 человека · 8 продуктов',
              members: [('А', PoraColors.sage), ('Б', PoraColors.primary)],
            ),
            const SizedBox(height: PoraSpacing.xl),
            for (final section in _sections)
              SectionGroup(section: section, colorOf: _colorOf),
          ],
        ),
      ),
    );
  }
}
