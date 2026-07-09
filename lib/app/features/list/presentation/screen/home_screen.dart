import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/list/domain/entity/list_item.dart';
import 'package:pora/app/features/list/presentation/widgets/add_list_button.dart';
import 'package:pora/app/features/list/presentation/widgets/list_header.dart';
import 'package:pora/app/features/list/presentation/widgets/section_group.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Главный экран — общий список покупок выбранной семьи.
///
/// [familyId] / [familyName] приходят из экрана выбора семьи (FamiliesPage).
/// Пока с демо-данными; при интеграции список берётся по familyId
/// (GET /families/{id}/lists) через MobX-стор + WebSocket.
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.familyId, this.familyName});

  /// Идентификатор выбранной семьи (null — семья по умолчанию).
  final String? familyId;

  /// Название семьи для заголовка (null — «Наш список»).
  final String? familyName;

  // Демо-данные (позже — из стора по familyId).
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
      floatingActionButton: AddListButton(
        onTap: () => context.router.push(const AddItemRoute()),
      ),
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
            ListHeader(
              title: familyName ?? context.l10n.listTitle,
              subtitle: context.l10n.listMembersCount,
              members: const [
                ('А', PoraColors.sage),
                ('Б', PoraColors.primary),
              ],
              onSearch: () => context.router.push(const SearchRoute()),
              onRecipe: () => context.router.push(const RecipeImportRoute()),
              onNotifications: () =>
                  context.router.push(const NotificationsRoute()),
            ),
            const SizedBox(height: PoraSpacing.xl),
            for (final section in _sections)
              SectionGroup(
                section: section,
                colorOf: _colorOf,
                onItemTap: (_) => context.router.push(const ItemDetailRoute()),
              ),
          ],
        ),
      ),
    );
  }
}
