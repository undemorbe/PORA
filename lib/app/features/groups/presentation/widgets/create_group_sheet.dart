import 'package:flutter/material.dart';
import 'package:pora/app/features/groups/presentation/store/groups_store.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';

Future<bool> showCreateGroupSheet(
  BuildContext context, {
  required GroupsStore store,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CreateGroupSheet(store: store),
  );
  return result ?? false;
}

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet({required this.store});
  final GroupsStore store;

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _controller = TextEditingController();
  bool _shared = true;
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
    final ok = await widget.store.createGroup(name: name, shared: _shared);
    if (!mounted) return;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
            Text(l.groupCreate, style: PoraText.title),
            const SizedBox(height: PoraSpacing.lg),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(hintText: l.groupNameHint),
            ),
            const SizedBox(height: PoraSpacing.lg),
            Row(
              children: [
                PoraChip(
                  label: l.groupShared,
                  dense: true,
                  selected: _shared,
                  onTap: () => setState(() => _shared = true),
                ),
                const SizedBox(width: PoraSpacing.sm),
                PoraChip(
                  label: l.groupPersonal,
                  dense: true,
                  selected: !_shared,
                  onTap: () => setState(() => _shared = false),
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l.cancel),
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
                        : Text(l.groupCreate),
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
