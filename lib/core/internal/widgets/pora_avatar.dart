import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

class PoraAvatar extends StatefulWidget {
  const PoraAvatar({
    super.key,
    required this.initial,
    this.color,
    this.size = PoraSizes.avatarXs,
    this.ring,
    this.imageUrl,
  });

  final String initial;
  final Color? color;
  final double size;
  final String? imageUrl;

  final Color? ring;

  @override
  State<PoraAvatar> createState() => _PoraAvatarState();
}

class _PoraAvatarState extends State<PoraAvatar> {
  String? _parsedImageUrl;
  Future<bool>? _imageValidation;

  @override
  void initState() {
    super.initState();
    _validateImageUrl();
  }

  @override
  void didUpdateWidget(covariant PoraAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _validateImageUrl();
    }
  }

  void _validateImageUrl() {
    final imageUrl = widget.imageUrl;
    _parsedImageUrl = imageUrl;
    _imageValidation = imageUrl == null || imageUrl.isEmpty
        ? Future.value(false)
        : compute(_hasAbsoluteImagePath, imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;

    final fallback = Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.color ?? PoraColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        widget.initial,
        style: TextStyle(
          fontFamily: kPoraFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: widget.size * 0.42,
          color: PoraColors.inkInverse,
        ),
      ),
    );

    Widget wrap(Widget child) {
      if (widget.ring == null) return child;
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.ring!, width: 2),
        ),
        child: Padding(padding: const EdgeInsets.all(2), child: child),
      );
    }

    return FutureBuilder<bool>(
      future: _imageValidation,
      builder: (context, snapshot) {
        final hasImage =
            snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true &&
            _parsedImageUrl == imageUrl;
        if (!hasImage) return wrap(fallback);

        return wrap(
          ClipOval(
            child: Image.network(
              imageUrl!,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                Logger.talker.warning(
                  'Avatar image failed: $imageUrl → $error',
                );
                return fallback;
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 90),
                  child: fallback,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

bool _hasAbsoluteImagePath(String imageUrl) {
  return Uri.tryParse(imageUrl)?.hasAbsolutePath == true;
}
