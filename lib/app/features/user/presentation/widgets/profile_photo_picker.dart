import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/user/presentation/store/user_profile_store.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

class ProfilePhotoPickerUserCreation extends StatelessWidget {
  const ProfilePhotoPickerUserCreation({
    super.key,
    this.onTap,
    required this.userProfileStore,
  });

  final VoidCallback? onTap;
  final UserProfileStore userProfileStore;

  ImageProvider? _getImageProvider(UserProfileStore store) {
    if (store.profileImage != null) {
      return FileImage(store.profileImage!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final imageProvider = _getImageProvider(userProfileStore);
        final isLoading = userProfileStore.isLoadingImage;
        return _buildPickerStack(context, imageProvider, isLoading);
      },
    );
  }

  Widget _buildPickerStack(
    BuildContext context,
    ImageProvider? imageProvider,
    bool? isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading == true ? null : onTap,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PoraColors.sandSoft,
                shape: BoxShape.circle,
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? const PhosphorIcon(
                      PhosphorIconsRegular.user,
                      size: 46,
                      color: PoraColors.primary,
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
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
