import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/core/features/invitation/presentation/store/invitations_store.dart';
import 'package:pora/core/features/invitation/presentation/widgets/invite_avatars.dart';
import 'package:pora/core/features/invitation/presentation/widgets/invite_code_card.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';
import 'package:pora/core/internal/widgets/screen_back_header.dart';

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
                    controller: codeController,
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

              PoraOutlineButton(
                label: context.l10n.householdConnectToFamily,
                //! Connect with invite code + deeplink
                onPressed: () async {
                  await invitationsStore
                      .connectToFamily(
                        code: invitationsStore.linkCode ?? widget.linkCode,
                      )
                      .whenComplete(() {
                        if (invitationsStore.isSuccess == true &&
                            context.mounted) {
                          PoraSnackbar.show(
                            context,
                            message: context.l10n.connectionSuccess,
                          );
                          context.router.pop();
                        }
                      });
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
                      color: context.colors.textSubtle,
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
