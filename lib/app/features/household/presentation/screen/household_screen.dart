import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/household/presentation/widgets/invite_avatars.dart';
import 'package:pora/app/features/household/presentation/widgets/invite_code_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';

/// Подключение партнёра к семье: код приглашения, ссылка, QR.
@RoutePage()
class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenBackHeader(title: context.l10n.householdInviteTitle),
              const SizedBox(height: 34),
              const InviteAvatars(),
              const SizedBox(height: 30),
              Text(
                context.l10n.householdCookTogether,
                style: PoraText.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PoraSpacing.md),
              Text(
                context.l10n.householdInviteDescription,
                style: PoraText.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const InviteCodeCard(code: 'PORA-4827'),
              const SizedBox(height: PoraSpacing.lg),
              PoraPrimaryButton(
                label: context.l10n.householdShareLink,
                onPressed: () {},
              ),
              const SizedBox(height: PoraSpacing.md),
              PoraOutlineButton(
                label: context.l10n.householdShowQr,
                onPressed: () {},
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    context.l10n.householdDoLater,
                    style: PoraText.bodyLarge.copyWith(
                      color: PoraColors.textSubtle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PoraSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
