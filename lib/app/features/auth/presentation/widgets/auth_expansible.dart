import 'package:flutter/material.dart';
import 'package:pora/app/features/auth/domain/enum/auth.dart';
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
        return AuthButton(text: isExpanded ? AppLocalizations.of(context)?.authSignInExpansibleCollapse : AppLocalizations.of(context)?.authSignInExpansibleExpand, 
        onPressed: (){//!add
        }, backgroundColor: AuthTypes.expansible.themeColor);
      },
      bodyBuilder: (context, animation) {
        return Column(
          children: [
            AuthButton(text: AppLocalizations.of(context)?.authSignInWithEmail, onPressed: (){//!add
            }, backgroundColor: AuthTypes.expansible.themeColor),
            AuthButton(text: AppLocalizations.of(context)?.authSignInWithGoogle, onPressed: (){//!add
            }, backgroundColor: AuthTypes.expansible.themeColor),
            AuthButton(text: AppLocalizations.of(context)?.authSignInWithApple, onPressed: (){//!add
            }, backgroundColor: AuthTypes.expansible.themeColor),
          ],
        );
      },
      controller: _controller,
    );
  }
}