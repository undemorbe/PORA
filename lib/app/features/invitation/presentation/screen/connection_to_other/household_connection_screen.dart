import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/features/invitation/presentation/store/invitations_store.dart';
import 'package:pora/app/features/invitation/presentation/widgets/invite_avatars.dart';
import 'package:pora/app/features/invitation/presentation/widgets/invite_code_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';

/// Подключение себя к семье

@RoutePage()
class InvitationConnectPage extends StatefulWidget {
  const InvitationConnectPage({
    super.key,
    @PathParam('linkCode') required this.linkCode,
  });

  final String linkCode;

  @override
  State<InvitationConnectPage> createState() => _InvitationConnectPageState();
}

class _InvitationConnectPageState extends State<InvitationConnectPage> {
  final InvitationsStore invitationsStore = InvitationsStore();
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenBackHeader(title: context.l10n.householdGotInvited),
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
                context.l10n.householdInviteDescriptionWhenConnecting,
                style: PoraText.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              //! Можно ввести самому
              Observer(
                builder: (_) {
                  return InviteCodeCard(
                    code: invitationsStore.linkCode ?? widget.linkCode,
                    onCopy: () async {
                      await invitationsStore
                          .copyToClipboard(
                            invitationsStore.linkCode ?? widget.linkCode,
                          )
                          .whenComplete(() {
                            if (context.mounted) {
                              PoraSnackbar.show(
                                context,
                                message: context.l10n.householdCopyCode,
                              );
                            }
                          });
                    },
                  );
                },
              ),
              const SizedBox(height: PoraSpacing.lg),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.words,
                style: PoraText.bodyLarge.copyWith(fontSize: 18),
                onChanged: (value) => invitationsStore.linkCode = value,
                decoration: InputDecoration(
                  hintText: context.l10n.householdWriteCode,
                ),
              ),
              const SizedBox(height: PoraSpacing.md),
              PoraOutlineButton(
                label: context.l10n.householdConnectToFamily,
                //! Connect with invite code + deeplink
                onPressed: () async {
                  await invitationsStore.connectToFamily(
                    code: invitationsStore.linkCode ?? widget.linkCode,
                  );
                },
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
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
