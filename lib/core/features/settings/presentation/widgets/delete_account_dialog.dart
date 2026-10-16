import 'package:flutter/material.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// Подтверждение безвозвратного удаления аккаунта (требование Google Play:
/// удаление должно быть доступно внутри приложения).
Future<bool> confirmDeleteAccount(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final c = context.colors;
      final l = context.l10n;
      return AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          l.deleteAccountTitle,
          style: PoraText.title.copyWith(color: c.ink),
        ),
        content: Text(
          l.deleteAccountBody,
          style: PoraText.body.copyWith(color: c.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: PoraColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.delete),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
