import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/features/families/presentation/store/families_store.dart';
import 'package:pora/app/features/families/presentation/widgets/family_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/widgets/pora_circle_progress.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';

class FamiliesListView extends StatelessWidget {
  final FamiliesStore store;

  const FamiliesListView({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
         if (store.isLoading == true) {
          return const Center(child: PoraCircleProgress());}
        else if (store.families.isEmpty) {
          return const Center(child: Text('No families found'));
        
        } else if (store.success == false) {
          PoraSnackbar.show(context, message: context.l10n.errorDuringLoading);
        }
            if (store.families.isEmpty) return const SizedBox.shrink();


        return ListView.builder(
          // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: 2, 
          //   crossAxisSpacing: 8.0,
          //   mainAxisSpacing: 8.0,
          //   childAspectRatio: 1.0, 
          // ),


          itemCount: store.families.length,
          itemBuilder: (context, index) {
            final family = store.families[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: PoraSpacing.md),
              child: FamilyCard(
                family: family,
                  onTap: () => context.router.push(
                    ListRoute(familyId: family.id, familyName: family.name),
                  ),
              ),
            );
          },
        );
      },
    );
  }
}
