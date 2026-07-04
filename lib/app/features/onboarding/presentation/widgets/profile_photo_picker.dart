import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Круглый пикер фото профиля с бейджем-камерой (UI; логику выбора добавит стор).
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: PoraColors.sandSoft,
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.user,
                size: 46,
                color: PoraColors.primary,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: const PhosphorIcon(
                  PhosphorIconsFill.camera,
                  size: 17,
                  color: PoraColors.inkInverse,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
