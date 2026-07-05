// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:pora/app/features/families/data/models/family_model.dart';
// import 'package:pora/app/features/families/domain/entity/family.dart';
// import 'package:pora/app/features/families/presentation/widgets/family_card.dart';
// import 'package:pora/app/internal/router/app_router.gr.dart';
// import 'package:pora/app/internal/theme/additional_constants.dart';
// import 'package:pora/app/internal/theme/app_text_styles.dart';
// import 'package:pora/app/internal/widgets/pora_buttons.dart';

// /// Выбор семьи: у пользователя может быть несколько семей — тап открывает её список.
// @RoutePage()
// class FamiliesPage extends StatelessWidget {
//    FamiliesPage({super.key});

//   // Демо-данные (позже — из бэкенда: GET /me/families).
//   final _families = <FamilyModel>[
//     FamilyModel(
//       id: 'fam1',
//       createdAt: 's1212',

//       name: 'Дом',
//       memberInitials: ['Б', 'А'],
//       itemCount: 8,
//       isCurrent: true,
//     ),
//     FamilyModel(
//       id: 'fam2',
//       name: 'Дача',
//       memberInitials: ['Б', 'А', 'М'],
//       itemCount: 3,
//     ),
//     FamilyModel(
//       id: 'fam3',
//       name: 'Родители',
//       memberInitials: ['Б', 'М'],
//       itemCount: 5,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(
//             PoraSpacing.screen,
//             6,
//             PoraSpacing.screen,
//             PoraSpacing.xxl,
//           ),
//           children: [
//             Text('Семьи', style: PoraText.title),
//             const SizedBox(height: 6),
//             Text(
//               'Выберите семью, чтобы открыть её список',
//               style: PoraText.caption,
//             ),
//             const SizedBox(height: PoraSpacing.xl),
//             for (final family in _families)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: PoraSpacing.md),
//                 child: FamilyCard(
//                   family: family,
//                   // TODO: передать family.id в список (HomePage), когда добавим параметр семьи.
//                   onTap: () => context.router.push(
//                     HomeRoute(familyId: family.id, familyName: family.name),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: PoraSpacing.sm),
//             PoraOutlineButton(
//               label: '＋ Создать или присоединиться',
//               onPressed: () => context.router.push(const HouseholdRoute()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
