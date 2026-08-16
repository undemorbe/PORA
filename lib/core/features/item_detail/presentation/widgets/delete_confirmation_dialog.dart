import 'package:flutter/material.dart';
import 'package:pora/core/features/item_detail/data/datasource/local_prefs.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Показывает подтверждение удаления с тумблером «Не спрашивать снова».
/// Если пользователь ранее выключил подтверждение — сразу возвращает `true`.
Future<bool> confirmDeleteItem(BuildContext context) async {
  final prefs = GetIt.I<ItemDetailsPrefs>();
  if (await prefs.shouldSkipDeleteConfirm()) return true;
  if (!context.mounted) return false;
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteDialog(),
  );
  return result ?? false;
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog();

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  bool _skip = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return AlertDialog(
      backgroundColor: c.surface,
      title: Text(
        l.deleteItemTitle,
        style: PoraText.title.copyWith(color: c.ink),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.deleteItemBody, style: PoraText.body.copyWith(color: c.ink)),
          const SizedBox(height: PoraSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.dontAskAgain,
                  style: PoraText.body.copyWith(color: c.textMuted),
                ),
              ),
              Switch.adaptive(
                value: _skip,
                onChanged: (v) => setState(() => _skip = v),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: PoraColors.danger),
          onPressed: () async {
            if (_skip) {
              await GetIt.I<ItemDetailsPrefs>().setSkipDeleteConfirm(true);
            }
            if (context.mounted) Navigator.of(context).pop(true);
          },
          child: Text(l.delete),
        ),
      ],
    );
  }
}
