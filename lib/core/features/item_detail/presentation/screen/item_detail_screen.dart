import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/item_detail/presentation/store/item_details_store.dart';
import 'package:pora/core/features/item_detail/presentation/widgets/added_by.dart';
import 'package:pora/core/features/item_detail/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:pora/core/features/item_detail/presentation/widgets/info_row.dart';
import 'package:pora/core/features/item_detail/presentation/widgets/notify_sheet.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_icon_tile.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/pora_setting_row.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';
import 'package:pora/core/internal/widgets/pora_toggle.dart';
import 'package:pora/core/internal/widgets/screen_back_header.dart';

/// Карточка товара: детали, тумблеры, удаление.
@RoutePage()
class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({
    super.key,
    required this.itemId,
    required this.additionalEffectOnDeletion,
  });

  final String itemId;
  final VoidCallback additionalEffectOnDeletion;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late final ItemDetailsStore store;

  @override
  void initState() {
    super.initState();
    store = ItemDetailsStore(itemId: widget.itemId);
    store.load();
  }

  Future<void> _toggleUrgent() async {
    final it = store.item;
    if (it == null) return;
    await store.save(urgent: !it.urgent);
  }

  Future<void> _notify() async {
    final it = store.item;
    if (it == null) return;
    final added = it.addedBy;
    if (added == null) {
      PoraSnackbar.show(context, message: context.l10n.nooneToNotify);
      return;
    }
    final sent = await showNotifySheet(
      context,
      store: store,
      itemName: it.name,
      fixedRecipients: [added.id],
    );
    if (!mounted || sent != true) return;
    PoraSnackbar.show(context, message: context.l10n.notifySent);
  }

  Future<void> _delete() async {
    final ok = await confirmDeleteItem(context);
    if (!ok || !mounted) return;
    final res = await store.delete().whenComplete(
      () => widget.additionalEffectOnDeletion(),
    );
    if (!mounted) return;
    if (res) {
      context.router.maybePop();
    } else {
      PoraSnackbar.show(
        context,
        message: store.errorMessage ?? context.l10n.errorGeneric,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Observer(
          builder: (context) {
            if (store.isLoading && store.item == null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final it = store.item;
            if (it == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(PoraSpacing.xl),
                  child: Text(
                    store.errorMessage ?? context.l10n.notFound,
                    style: PoraText.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return _Body(
              item: it,
              store: store,
              onDelete: _delete,
              onToggleUrgent: _toggleUrgent,
              onNotify: _notify,
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.item,
    required this.store,
    required this.onDelete,
    required this.onToggleUrgent,
    required this.onNotify,
  });

  final ProductEntity item;
  final ItemDetailsStore store;
  final VoidCallback onDelete;
  final VoidCallback onToggleUrgent;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PoraSpacing.screen,
        PoraSpacing.sm,
        PoraSpacing.screen,
        PoraSpacing.xxl,
      ),
      children: [
        ScreenBackHeader(title: item.name),
        const SizedBox(height: PoraSpacing.lg),
        Center(
          child: Column(
            children: [
              PoraIconTile.emoji(
                '🥛',
                color: PoraColors.sand,
                size: 80,
                emojiSize: 40,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
              ),
              const SizedBox(height: 14),
              Text(item.name, style: PoraText.title),
            ],
          ),
        ),
        const SizedBox(height: PoraSpacing.xxl),
        PoraRowsCard(
          children: [
            if (item.addedBy != null)
              InfoRow(
                label: context.l10n.itemDetailAddedBy,
                trailing: AddedBy(member: item.addedBy!),
              ),
            InfoRow(
              label: context.l10n.itemDetailQuantity,
              value: '${item.quantity} ${item.unit}'.trim(),
            ),
            InfoRow(
              label: context.l10n.priorityLabel,
              value: item.priority.toString(),
            ),
          ],
        ),
        const SizedBox(height: PoraSpacing.lg),
        PoraRowsCard(
          children: [
            PoraSettingRow(
              icon: PhosphorIconsRegular.clock,
              label: context.l10n.itemDetailUrgent,
              trailing: GestureDetector(
                onTap: onToggleUrgent,
                child: PoraToggle(value: item.urgent),
              ),
            ),
            if (item.remindEveryDay != null)
              PoraSettingRow(
                icon: PhosphorIconsRegular.arrowsClockwise,
                label: context.l10n.itemDetailRemind,
                subtitle: context.l10n.everyDay,
                trailing: const PoraToggle(value: true),
              ),
          ],
        ),
        const SizedBox(height: PoraSpacing.xl),
        PoraPrimaryButton(label: context.l10n.notify, onPressed: onNotify),
        const SizedBox(height: PoraSpacing.md),
        PoraPrimaryButton(
          label: item.checked
              ? context.l10n.returnToList
              : context.l10n.itemDetailMarkBought,
          onPressed: () => store.toggleBought(),
        ),
        const SizedBox(height: PoraSpacing.lg),
        Center(
          child: TextButton(
            onPressed: onDelete,
            child: Text(
              context.l10n.itemDetailDelete,
              style: PoraText.bodyLarge.copyWith(
                color: PoraColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
