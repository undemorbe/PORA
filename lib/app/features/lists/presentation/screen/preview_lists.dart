import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/features/lists/presentation/widgets/add_list_button.dart';
import 'package:pora/app/features/lists/presentation/widgets/create_list_sheet.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_header.dart';
import 'package:pora/app/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';

/// Превью списков покупок семьи: карточки со списками + high-priority секциями.
@RoutePage()
class PreviewListsPage extends StatefulWidget {
  const PreviewListsPage({
    super.key,
    required this.familyId,
    required this.familyName,
    required this.members,
  });
  final String familyId;
  final String familyName;
  final List<MemberEntity> members;

  @override
  State<PreviewListsPage> createState() => _PreviewListsPageState();
}

class _PreviewListsPageState extends State<PreviewListsPage> {
  late final ListStore listStore;

  @override
  void initState() {
    super.initState();
    listStore = ListStore()..getFamilyLists(fid: widget.familyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AddListButton(
        onTap: () => showCreateListSheet(
          context,
          listStore: listStore,
          familyId: widget.familyId,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: () => listStore.getFamilyLists(fid: widget.familyId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PoraSpacing.screen,
              PoraSpacing.sm,
              PoraSpacing.screen,
              100,
            ),
            children: [
              Observer(
                builder: (context) {
                  final count =
                      listStore.listsWithPreview?.lists.length ?? 0;
                  return ListHeader(
                    title: widget.familyName,
                    subtitle:
                        "${widget.members.length} ${context.l10n.human} · $count ${context.l10n.lists}",
                    members: widget.members,
                  );
                },
              ),
              const SizedBox(height: PoraSpacing.xl),
              SectionBuilder(
                listStore: listStore,
                isPreview: true,
                members: widget.members,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
