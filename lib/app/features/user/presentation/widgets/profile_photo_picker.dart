import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/user/presentation/store/user_profile_store.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

class ProfilePhotoPicker extends StatefulWidget {
  const ProfilePhotoPicker({super.key, this.onTap, required this.userProfileStore});

  final VoidCallback? onTap;
  final UserProfileStore userProfileStore;
  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            Observer(
              builder: (_) {
                return Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: PoraColors.sandSoft,
                    shape: BoxShape.circle,
                  ),
                  child: widget.userProfileStore.profileImage != null
                      ? Image.file(widget.userProfileStore.profileImage!)
                      : const PhosphorIcon(
                          PhosphorIconsRegular.user,
                          size: 46,
                          color: PoraColors.primary,
                        ),
                );
              },
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
