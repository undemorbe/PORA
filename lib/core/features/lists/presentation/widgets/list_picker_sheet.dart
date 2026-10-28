import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Модальный выбор списка. Возвращает `list.id` выбранного списка (или `null`,
/// если закрыли). Источник списков — общий [GroupsStore].
Future<String?> showListPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ListPickerSheet(),
  );
}

class _ListPickerSheet extends StatelessWidget {
  const _ListPickerSheet();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final store = GetIt.I<GroupsStore>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: PoraRadii.cardR),
        ),
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.lg,
          PoraSpacing.md,
          PoraSpacing.lg,
          PoraSpacing.lg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: PoraSpacing.lg),
              Text(l.listPickerTitle, style: PoraText.navTitle),
              const SizedBox(height: PoraSpacing.md),
              Flexible(
                child: Observer(
                  builder: (_) {
                    if (store.groups.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: PoraSpacing.lg,
                        ),
                        child: Text(
                          l.listPickerEmpty,
                          style: PoraText.small.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: store.groups.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: PoraSpacing.sm),
                      itemBuilder: (_, i) {
                        final g = store.groups[i];
                        return PressScale(
                          onTap: () => Navigator.of(context).pop(g.list.id),
                          child: Container(
                            padding: const EdgeInsets.all(PoraSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.surfaceAlt,
                              borderRadius: PoraRadii.input,
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  g.isPersonal
                                      ? PhosphorIconsRegular.user
                                      : PhosphorIconsRegular.usersThree,
                                  size: 20,
                                  color: PoraColors.primary,
                                ),
                                const SizedBox(width: PoraSpacing.md),
                                Expanded(
                                  child: Text(
                                    g.list.name,
                                    style: PoraText.itemTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (g.isPersonal)
                                  Text(
                                    l.personal,
                                    style: PoraText.micro.copyWith(
                                      color: colors.textSubtle,
                                    ),
                                  ),
                                const SizedBox(width: PoraSpacing.xs),
                                const Icon(
                                  PhosphorIconsRegular.caretRight,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
