// import 'package:flutter/material.dart';
// import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// import 'package:pora/app/features/families/domain/entity/family.dart';
// import 'package:pora/app/internal/theme/additional_constants.dart';
// import 'package:pora/app/internal/theme/app_text_styles.dart';
// import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
// import 'package:pora/app/internal/widgets/pora_avatar.dart';
// import 'package:pora/app/internal/widgets/pora_card.dart';
// import 'package:pora/app/internal/widgets/pora_pill.dart';

// /// Карточка семьи в списке выбора: аватары участников, название, счётчик, метка «Текущая».
// class FamilyCard extends StatelessWidget {
//   const FamilyCard({super.key, required this.family, this.onTap});

//   final Family family;
//   final VoidCallback? onTap;

//   static const _avatarColors = [
//     PoraColors.primary,
//     PoraColors.sage,
//     PoraColors.primaryDark,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final ring = Theme.of(context).colorScheme.surface;
//     final members = family.memberInitials;
//     final avatarsWidth = members.isEmpty
//         ? 0.0
//         : 32 + (members.length - 1) * 20.0;

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: onTap,
//       child: PoraCard(
//         padding: const EdgeInsets.symmetric(
//           horizontal: PoraSpacing.lg,
//           vertical: 14,
//         ),
//         child: Row(
//           children: [
//             SizedBox(
//               width: avatarsWidth,
//               height: 32,
//               child: Stack(
//                 children: [
//                   for (var i = 0; i < members.length; i++)
//                     Positioned(
//                       left: i * 20.0,
//                       child: PoraAvatar(
//                         initial: members[i],
//                         color: _avatarColors[i % _avatarColors.length],
//                         size: 32,
//                         ring: ring,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: PoraSpacing.md),
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Flexible(
//                         child: Text(
//                           family.name,
//                           style: PoraText.button,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       if (family.isCurrent) ...[
//                         const SizedBox(width: PoraSpacing.sm),
//                         const PoraPill(label: 'Текущая'),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     '${members.length} человека · ${family.itemCount} продуктов',
//                     style: PoraText.small,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: PoraSpacing.sm),
//             const PhosphorIcon(
//               PhosphorIconsRegular.caretRight,
//               size: 20,
//               color: Color(0xFFC9BEAE),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
