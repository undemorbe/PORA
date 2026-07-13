// import 'package:flutter/material.dart';
// import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// import 'package:pora/app/features/families/domain/entity/shopping_list.dart';
// import 'package:pora/app/features/families/presentation/widgets/product_preview.dart';
// import 'package:pora/app/internal/theme/additional_constants.dart';
// import 'package:pora/app/internal/theme/app_text_styles.dart';
// import 'package:pora/app/internal/widgets/pora_card.dart';

// /// Тайл списка покупок внутри семьи (у семьи их может быть несколько):
// /// название + превью срочных продуктов. Тап открывает список.
// class FamilyListTile extends StatelessWidget {
//   const FamilyListTile({super.key, required this.list, this.onTap});

//   final ShoppingListEntity list;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
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
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     list.name,
//                     style: PoraText.button,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   ProductPreview(products: list.highPriorityProducts),
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
