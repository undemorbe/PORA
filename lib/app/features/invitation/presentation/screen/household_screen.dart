import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/invitation/presentation/store/invitations_store.dart';
import 'package:pora/app/features/invitation/presentation/widgets/invite_avatars.dart';
import 'package:pora/app/features/invitation/presentation/widgets/invite_code_card.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_circle_progress.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

/// Подключение партнёра к семье: код приглашения, ссылка, QR.
@RoutePage()
class InvitePage extends StatefulWidget {
  const InvitePage({super.key, required this.familyId});

  final String familyId;

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  final InvitationsStore invitationsStore = InvitationsStore();

  @override
  void initState() {
    super.initState();
    generateLinkCodes();
  }

  void generateLinkCodes() async {
    await invitationsStore.generateLinkCode(familyId: widget.familyId);
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
              Observer(
                builder: (_) {
                  if (invitationsStore.isLoading == true) {
                    return const Center(child: PoraCircleProgress());
                  } else if (invitationsStore.isSuccess == true) {
                    return InviteCodeCard(
                      controller: null,
                      onCopy: () async {
                        await invitationsStore
                            .copyToClipboard(
                              invitationsStore.linkCode ?? 'Error',
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
                      code:
                          invitationsStore.linkCode ?? context.l10n.commonError,
                    );
                  } else if (invitationsStore.isSuccess == false) {
                    return Center(child: Text(context.l10n.commonError));
                  }

                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.tryToUpdate),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            invitationsStore.generateLinkCode(
                              familyId: widget.familyId,
                            );
                          },
                          icon: const PhosphorIcon(
                            PhosphorIcons.arrowsClockwiseDuotone,
                          ), // Changed to an appropriate action icon
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: PoraSpacing.lg),
              PoraPrimaryButton(
                label: context.l10n.householdShareLink,
                onPressed: () async {
                  await invitationsStore.shareLinkCode(
                    linkCodeOrLinkUrl:
                        invitationsStore.linkUrl ??
                        invitationsStore.linkCode ??
                        'Error sharing code',
                  );
                },
              ),
              const SizedBox(height: PoraSpacing.md),
              PoraOutlineButton(
                label: context.l10n.householdShowQr,
                onPressed: () async {
                  await showDialog(
                    context: context,
                    fullscreenDialog: false,
                    builder: (context) {
                      //! Check
                      return Align(
                        alignment: const AlignmentGeometry.xy(0, -.3),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          margin: const .all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(24.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: PrettyQrView.data(
                            decoration: const PrettyQrDecoration(
                              background: Colors.transparent,
                              shape: PrettyQrSmoothSymbol(
                                roundFactor: 0.5,
                                color: PrettyQrBrush.gradient(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFE07A5F),
                                      Color(0xFFFBE3DC),
                                    ],
                                    begin: .topLeft,
                                    end: .bottomRight,
                                  ),
                                ),
                              ),
                              image: PrettyQrDecorationImage(
                                image: AssetImage('assets/app_logo.png'),
                                position:
                                    PrettyQrDecorationImagePosition.embedded,
                              ),
                            ),

                            data:
                                invitationsStore.linkUrl ??
                                context.l10n.commonError,
                          ),
                        ),
                      );
                    },
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
