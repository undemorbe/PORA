import 'package:flutter/material.dart';
import 'package:pora/core/features/auth_and_validation/presentation/controller/privacy_store.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';

/// Единая privacy-ссылка для auth-flow. Убирает копипасту `InkWell + Text
/// underlined` в двух местах (auth_screen + auth_otp_confirm).
class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key, required this.store});
  final PrivacyStore store;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: store.openPrivacy,
      child: Text(
        context.l10n.authPrivatePolicy,
        style: PoraText.small.copyWith(
          height: 1.4,
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
