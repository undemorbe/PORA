import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/item_detail/presentation/store/item_details_store.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';

/// Bottom-sheet отправки уведомления о товаре.
///
/// Backend требует **user_id** — свободный ввод превращается в suggestion
/// по [candidates]. Если ничего не выбрано и `to == null` — шлём всем.
///
/// [fixedRecipients] — фиксированный список получателей, UI выбора не
/// показывается. Используется в item detail (уведомляем только `addedBy`).
Future<bool?> showNotifySheet(
  BuildContext context, {
  required ItemDetailsStore store,
  required String itemName,
  List<MemberEntity> candidates = const [],
  List<String>? fixedRecipients,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _NotifySheet(
      store: store,
      itemName: itemName,
      candidates: candidates,
      fixedRecipients: fixedRecipients,
    ),
  );
}

class _NotifySheet extends StatefulWidget {
  const _NotifySheet({
    required this.store,
    required this.itemName,
    required this.candidates,
    required this.fixedRecipients,
  });

  final ItemDetailsStore store;
  final String itemName;
  final List<MemberEntity> candidates;
  final List<String>? fixedRecipients;

  @override
  State<_NotifySheet> createState() => _NotifySheetState();
}

class _NotifySheetState extends State<_NotifySheet> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  /// user id → отмечен.
  final Set<String> _selectedIds = <String>{};
  bool _busy = false;
  String _query = '';

  bool get _isFixed => widget.fixedRecipients != null;

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MemberEntity> get _suggestions {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.candidates
        .where(
          (m) =>
              !_selectedIds.contains(m.id) &&
              (m.name.toLowerCase().contains(q) ||
                  (m.surname ?? '').toLowerCase().contains(q)),
        )
        .toList();
  }

  void _toggleMember(MemberEntity m) {
    setState(() {
      if (_selectedIds.contains(m.id)) {
        _selectedIds.remove(m.id);
      } else {
        _selectedIds.add(m.id);
      }
    });
  }

  void _pickSuggestion(MemberEntity m) {
    setState(() {
      _selectedIds.add(m.id);
      _searchController.clear();
      _query = '';
    });
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    final List<String>? to = _isFixed
        ? widget.fixedRecipients
        : (_selectedIds.isEmpty ? null : _selectedIds.toList());
    final ok = await widget.store.notify(
      to: to,
      message: _messageController.text.trim(),
    );
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.notify, style: PoraText.title),
              const SizedBox(height: PoraSpacing.lg),

              if (!_isFixed) ...[
                Text(l.notifyRecipients, style: PoraText.overline),
                const SizedBox(height: PoraSpacing.sm),
                _EveryoneChip(
                  selected: _selectedIds.isEmpty,
                  onTap: () => setState(_selectedIds.clear),
                  label: l.notifyEveryone,
                ),
                if (widget.candidates.isNotEmpty) ...[
                  const SizedBox(height: PoraSpacing.sm),
                  Wrap(
                    spacing: PoraSpacing.sm,
                    runSpacing: PoraSpacing.sm,
                    children: [
                      for (final m in widget.candidates)
                        _MemberChip(
                          member: m,
                          selected: _selectedIds.contains(m.id),
                          onTap: () => _toggleMember(m),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: PoraSpacing.md),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l.notifyAddCustom,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: PoraSpacing.md,
                      vertical: PoraSpacing.md,
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: PoraSpacing.xs),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: PoraRadii.input,
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final m in _suggestions)
                          InkWell(
                            onTap: () => _pickSuggestion(m),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PoraSpacing.md,
                                vertical: PoraSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  PoraAvatar(
                                    initial: m.name.isEmpty ? '?' : m.name[0],
                                    color: memberColor(m, 0),
                                    size: 24,
                                    imageUrl: m.imageUrl,
                                  ),
                                  const SizedBox(width: PoraSpacing.sm),
                                  Text(
                                    m.surname == null
                                        ? m.name
                                        : '${m.name} ${m.surname}',
                                    style: PoraText.body,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: PoraSpacing.lg),
              ],

              Text(l.notifyMessageLabel, style: PoraText.overline),
              const SizedBox(height: PoraSpacing.sm),
              TextField(
                controller: _messageController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l.notifyHint(widget.itemName),
                ),
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
                      onPressed: _busy ? null : _send,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: PoraColors.inkInverse,
                              ),
                            )
                          : Text(l.notifySend),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EveryoneChip extends StatelessWidget {
  const _EveryoneChip({
    required this.selected,
    required this.onTap,
    required this.label,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.md,
          vertical: PoraSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? PoraColors.primaryTint : Colors.transparent,
          border: Border.all(
            color: selected ? PoraColors.primary : context.colors.border,
          ),
          borderRadius: PoraRadii.pill,
        ),
        child: Text(
          label,
          style: PoraText.button.copyWith(
            color: selected ? PoraColors.primaryDark : context.colors.ink,
          ),
        ),
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  final MemberEntity member;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.xs,
          PoraSpacing.xs,
          PoraSpacing.md,
          PoraSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? PoraColors.primaryTint : Colors.transparent,
          border: Border.all(
            color: selected ? PoraColors.primary : context.colors.border,
          ),
          borderRadius: PoraRadii.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PoraAvatar(
              initial: member.name.isEmpty ? '?' : member.name[0],
              color: memberColor(member, 0),
              size: 24,
              imageUrl: member.imageUrl,
            ),
            const SizedBox(width: PoraSpacing.sm),
            Text(member.name, style: PoraText.body),
          ],
        ),
      ),
    );
  }
}
