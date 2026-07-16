import 'package:flutter/material.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Диалог подтверждения удаления списка. Без «не спрашивать» — удаление
/// списка более редкое и деструктивное действие чем items.
Future<bool> confirmDeleteList(BuildContext context, {required String listName}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) {
      final c = context.colors;
      final l = context.l10n;
      return AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          l.deleteListTitle,
          style: PoraText.title.copyWith(color: c.ink),
        ),
        content: Text(
          l.deleteListBody(listName),
          style: PoraText.body.copyWith(color: c.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: PoraColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.delete),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
