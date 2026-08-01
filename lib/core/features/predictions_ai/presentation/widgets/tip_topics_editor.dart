import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/presentation/store/tip_topics_store.dart';
import 'package:pora/core/features/predictions_ai/presentation/topic_resolver.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/press_scale.dart';

/// Полный редактор списка тем совета — для встраивания в advanced settings.
/// Состоит из: описания, chip-грид predefined (toggle),
/// chip-грид custom (delete), input add-новой темы.
class TipTopicsEditor extends StatefulWidget {
  const TipTopicsEditor({super.key});

  @override
  State<TipTopicsEditor> createState() => _TipTopicsEditorState();
}

class _TipTopicsEditorState extends State<TipTopicsEditor> {
  final TipTopicsStore _store = GetIt.I<TipTopicsStore>();
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final v = _input.text.trim();
    if (v.isEmpty) return;
    await _store.addCustom(v);
    _input.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Observer(
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(PoraSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: PoraRadii.card,
            border: Border.all(color: c.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.tipTopicsSectionDescription,
                style: PoraText.small.copyWith(color: c.textSubtle),
              ),
              if (_store.activeTopics.isEmpty) ...[
                const SizedBox(height: PoraSpacing.sm),
                Text(
                  l.tipTopicsEmpty,
                  style:
                      PoraText.small.copyWith(color: PoraColors.danger),
                ),
              ],
              const SizedBox(height: PoraSpacing.md),
              Text(
                l.tipTopicsPredefinedLabel,
                style: PoraText.small.copyWith(
                  color: c.textSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in _store.predefinedWithState)
                    _ToggleChip(
                      label: TopicResolver.resolve(item.topic, l),
                      active: item.enabled,
                      onTap: () => _store.togglePredefined(item.topic.id),
                    ),
                ],
              ),
              const SizedBox(height: PoraSpacing.md),
              Text(
                l.tipTopicsCustomLabel,
                style: PoraText.small.copyWith(
                  color: c.textSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              if (_store.customTopics.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in _store.customTopics)
                      _RemovableChip(
                        label: t.rawText ?? '',
                        onRemove: () =>
                            _store.removeCustom(t.rawText ?? ''),
                      ),
                  ],
                ),
              const SizedBox(height: PoraSpacing.sm),
              TextField(
                controller: _input,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: PoraText.bodyLarge,
                decoration: InputDecoration(
                  hintText: l.tipTopicsAddCustom,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _AddBtn(onTap: _submit),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 46,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? PoraColors.primary : c.surfaceAlt,
          borderRadius: PoraRadii.pill,
          border: Border.all(
            color: active ? PoraColors.primary : c.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active
                  ? PhosphorIconsBold.check
                  : PhosphorIconsRegular.plus,
              size: 12,
              color: active ? Colors.white : c.textSubtle,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: PoraText.small.copyWith(
                color: active ? Colors.white : c.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PoraColors.primary.withValues(alpha: 0.12),
        borderRadius: PoraRadii.pill,
        border: Border.all(
          color: PoraColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: PoraText.small.copyWith(
              color: c.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              PhosphorIconsRegular.x,
              size: 14,
              color: PoraColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  const _AddBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: PoraColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          PhosphorIconsBold.plus,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
