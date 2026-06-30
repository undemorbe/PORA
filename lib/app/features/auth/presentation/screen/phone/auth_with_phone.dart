
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/auth/presentation/widgets/text_fields/phone_field.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';

@RoutePage()
class AuthWithPhone extends StatelessWidget {
  const AuthWithPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //! Localize
        title: Text(AppLocalizations.of(context)!.authSignInWithPhone, style: Theme.of(context).textTheme.bodySmall,),
      ),
      body: const Center(
            // Input field
            child: Padding(
              padding: .symmetric(horizontal: 24),
              child: PhoneInputField()),        
      ),
    );
  }
}