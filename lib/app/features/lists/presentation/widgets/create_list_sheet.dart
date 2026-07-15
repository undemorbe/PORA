import 'package:flutter/material.dart';
import 'package:pora/app/features/lists/presentation/store/lists_store.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Bottom-sheet «Новый список»: TextField + Создать.
/// Возвращает `true` если список создан.
Future<bool> showCreateListSheet(
  BuildContext context, {
  required ListStore listStore,
  required String familyId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _CreateListSheet(
      listStore: listStore,
      familyId: familyId,
    ),
  );
  return result ?? false;
}

class _CreateListSheet extends StatefulWidget {
  const _CreateListSheet({required this.listStore, required this.familyId});

  final ListStore listStore;
  final String familyId;

  @override
  State<_CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<_CreateListSheet> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _busy) return;
    setState(() => _busy = true);
    await widget.listStore.createList(name: name, fid: widget.familyId);
    if (!mounted) return;
    final ok = widget.listStore.isSuccess == true;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.screen,
          PoraSpacing.xl,
          PoraSpacing.screen,
          PoraSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.newList, style: PoraText.title),
            const SizedBox(height: PoraSpacing.lg),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: context.l10n.listNamePlaceholder,
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: PoraSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PoraColors.inkInverse,
                            ),
                          )
                        : Text(context.l10n.familiesCreate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
