import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/core/features/families/presentation/store/families_store.dart';
import 'package:pora/core/features/families/presentation/widgets/families_create_button.dart';
import 'package:pora/core/features/families/presentation/widgets/families_list_view.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:pora/core/internal/network/websocket/debouncer.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';

/// Выбор семьи: у пользователя может быть несколько семей — тап открывает её.
@RoutePage()
class FamiliesPage extends StatefulWidget {
  const FamiliesPage({super.key});

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage>
    with TickerProviderStateMixin {
  late final TextEditingController familyTextController;

  late final FamiliesStore familiesStore;
  StreamSubscription<WsDataModel>? subscription;
  final debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    familyTextController = TextEditingController();
    familiesStore = FamiliesStore();
    subscription = AppWebsocket.instance.events.listen((event) {
      if (event.fid != null && event.iid == null && event.lid == null) {
        debouncer.call(() {
          familiesStore.getFamilies();
        });
      }
    });
  }

  @override
  void dispose() {
    familyTextController.dispose();
    subscription?.cancel();
    debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    familiesStore.getFamilies();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            6,
            PoraSpacing.screen,
            PoraSpacing.xxs,
          ),
          child: RefreshIndicator.adaptive(
            onRefresh: () => familiesStore.getFamilies(),
            child: Column(
              mainAxisSize: .max,
              mainAxisAlignment: .spaceBetween,

              children: [
                Column(
                  mainAxisSize: .min,
                  children: [
                    Text(l.familiesTitle, style: PoraText.title),
                    const SizedBox(height: 6),
                    Text(l.familiesSubtitle, style: PoraText.caption),
                    const SizedBox(height: PoraSpacing.xl),
                  ],
                ),

                Expanded(child: FamiliesListView(store: familiesStore)),

                Column(
                  mainAxisSize: .min,
                  children: [
                    const SizedBox(height: PoraSpacing.sm),
                    PoraOutlineButton(
                      label: l.familiesConnect,
                      onPressed: () {
                        context.router.push(
                          InvitationConnectRoute(linkCode: '8QwR...'),
                        );
                      },
                    ),
                    FamiliesCreateButton(
                      familyTextController: familyTextController,
                      familiesStore: familiesStore,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
