import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/families/data/models/family_model.dart';
import 'package:pora/app/features/families/data/models/member_model.dart';
import 'package:pora/app/features/families/data/models/product_model.dart';
import 'package:pora/app/features/families/data/models/shopping_list_model.dart';
import 'package:pora/app/features/families/presentation/widgets/family_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';

/// Выбор семьи: у пользователя может быть несколько семей — тап открывает её.
@RoutePage()
class FamiliesPage extends StatelessWidget {
  FamiliesPage({super.key});

  // Демо-данные (позже — из стора: GET /me/families).
  // high-priority продукты и списки отдаёт бэкенд уже готовыми.
  static const _boris = MemberModel(
    id: 'u1',
    name: 'Борис',
    imageUrl: null,
    joinedAt: '2024-01-01',
    colorCode: '#E07A5F',
  );
  static const _anna = MemberModel(
    id: 'u2',
    name: 'Анна',
    imageUrl: null,
    joinedAt: '2024-02-01',
    colorCode: '#8AA399',
  );
  static const _mark = MemberModel(
    id: 'u3',
    name: 'Марк',
    imageUrl: null,
    joinedAt: '2024-03-01',
    colorCode: '#C15B3F',
  );

  final _families = <FamilyModel>[
    const FamilyModel(
      id: 'fam1',
      name: 'Дом',
      createdAt: '2024-01-01',
      isCurrent: true,
      membersModels: const [_boris, _anna],
      ownerModel: _boris,
      highPriorityProductsModels: const [
        ProductModel(id: 'p1', name: 'Молоко', emoji: '🥛'),
        ProductModel(id: 'p2', name: 'Кофе', emoji: '☕'),
        ProductModel(id: 'p3', name: 'Хлеб', emoji: '🍞'),
        ProductModel(id: 'p4', name: 'Яйца', emoji: '🥚'),
      ],
      listsModels: const [
        ShoppingListModel(
          id: 'l1',
          name: 'Продукты',
          highPriorityProductsModels: [
            ProductModel(id: 'p1', name: 'Молоко', emoji: '🥛'),
            ProductModel(id: 'p2', name: 'Кофе', emoji: '☕'),
          ],
        ),
        ShoppingListModel(
          id: 'l2',
          name: 'Бытовое',
          highPriorityProductsModels: [
            ProductModel(id: 'p5', name: 'Порошок', emoji: '🧼'),
          ],
        ),
      ],
    ),
    const FamilyModel(
      id: 'fam2',
      name: 'Дача',
      createdAt: '2024-04-01',
      isCurrent: false,
      membersModels: const [_boris, _anna, _mark],
      ownerModel: _anna,
      highPriorityProductsModels: const [
        ProductModel(id: 'p6', name: 'Уголь', emoji: '🔥'),
        ProductModel(id: 'p7', name: 'Вода', emoji: '💧'),
      ],
      listsModels: const [
        ShoppingListModel(
          id: 'l3',
          name: 'Шашлык',
          highPriorityProductsModels: [
            ProductModel(id: 'p6', name: 'Уголь', emoji: '🔥'),
          ],
        ),
      ],
    ),
    const FamilyModel(
      id: 'fam3',
      name: 'Родители',
      createdAt: '2024-05-01',
      isCurrent: false,
      membersModels: const [_boris, _mark],
      ownerModel: _mark,
      highPriorityProductsModels: const [],
      listsModels: const [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            6,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            Text(l.familiesTitle, style: PoraText.title),
            const SizedBox(height: 6),
            Text(l.familiesSubtitle, style: PoraText.caption),
            const SizedBox(height: PoraSpacing.xl),
            for (final family in _families)
              Padding(
                padding: const EdgeInsets.only(bottom: PoraSpacing.md),
                child: FamilyCard(
                  family: family,
                  onTap: () => context.router.push(
                    HomeRoute(familyId: family.id, familyName: family.name),
                  ),
                ),
              ),
            const SizedBox(height: PoraSpacing.sm),
            PoraOutlineButton(
              label: l.familiesCreateOrJoin,
              onPressed: () =>
                  context.router.push(HouseholdRoute(familyId: '')),
            ),
          ],
        ),
      ),
    );
  }
}
