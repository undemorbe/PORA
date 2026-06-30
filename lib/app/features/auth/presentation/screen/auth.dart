import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pora/app/features/auth/domain/entity/auth_types.dart';
import 'package:pora/app/features/auth/presentation/widgets/auth_button.dart';
import 'package:pora/app/features/auth/presentation/widgets/auth_expansible.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';


@RoutePage()
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Column(
        
        children: [
          SizedBox(
            height: 145 + mediaQuery.size.height * 0.15,
          ),
          Column(
            mainAxisAlignment: .spaceBetween,
            children: [
              //icon
              Column(
                crossAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: PoraColors.sand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsBold.caretRight,
                      size: 50,
                    ),
                  ),
                  const Padding(padding: .only(top: 50)),
                  Text(
                     AppLocalizations.of(context)!.appName,
                     style: theme.textTheme.headlineLarge,
                  ),
                  Text(
                    AppLocalizations.of(context)!.authUnderAppName1,
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    AppLocalizations.of(context)!.authUnderAppName2,
                    style: PoraText.bodyLarge,
                  ),
                ],
                
              ),
              //log
              Column(
                crossAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                   AuthButton(text: AppLocalizations.of(context)!.authSignInWithPhone, onPressed: () {}, backgroundColor: AuthTypes.phone.themeColor),
                   const AuthExpansible(),
                   Padding(
                    padding: const .symmetric(vertical: 24, horizontal: 45),
                    child: Text(AppLocalizations.of(context)!.authPrivatePolicy, style: theme.textTheme.bodySmall)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}