import 'package:flutter/material.dart';
import 'package:pora/app/features/auth/domain/entity/auth_types.dart';
import 'package:pora/app/features/auth/presentation/widgets/auth_button.dart';
import 'package:pora/app/internal/localization/l10n/generated/app_localizations.dart';


class AuthExpansible extends StatefulWidget {
  const AuthExpansible({super.key});

  @override
  State<AuthExpansible> createState() => _AuthExpansibleState();
}

class _AuthExpansibleState extends State<AuthExpansible> {
  final ExpansibleController _controller = ExpansibleController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expansible(
      headerBuilder: (context, animation) {
        final isExpanded = _controller.isExpanded;
        return AuthButton(text: isExpanded ? AppLocalizations.of(context)?.authSignInExpansibleCollapse??'Collapse' : AppLocalizations.of(context)?.authSignInExpansibleExpand??'Expand', 
        onPressed: (){//!add
        }, backgroundColor: AuthTypes.expansible.themeColor);
      },
      bodyBuilder: (context, animation) {
        return Column(
          children: [
            AuthButton(text: AppLocalizations.of(context)?.authSignInWithEmail??'email', onPressed: (){//!add
            }, backgroundColor: AuthTypes.email.themeColor),
            AuthButton(text: AppLocalizations.of(context)?.authSignInWithGoogle??'google', onPressed: (){//!add
            }, backgroundColor: AuthTypes.google.themeColor ),
            AuthButton(text: AppLocalizations.of(context)?.authSignInWithApple??'apple', onPressed: (){//!add
            }, backgroundColor: AuthTypes.apple.themeColor),
          ],
        );
      },
      controller: _controller,
    );
  }
}