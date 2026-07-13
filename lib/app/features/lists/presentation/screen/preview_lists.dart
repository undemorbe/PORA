import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/features/lists/presentation/widgets/add_list_button.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_header.dart';
import 'package:pora/app/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';

/// Конкретный список покупок выбранной семьи.
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
  /// Контроллер
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
        onTap: () => context.router.push(const AddItemRoute()),
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
              100, // место под плавающую кнопку
            ),
            children: [
              ListHeader(
                //! Do search, recipe, notifications
                title: widget.familyName,
                subtitle:
                    "${widget.members.length} ${context.l10n.human} · ${listStore.listsWithPreview?.lists?.length} ${context.l10n.lists}",
                members: widget.members,
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
