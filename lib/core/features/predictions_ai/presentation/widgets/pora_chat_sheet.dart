import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/domain/usecase/chat_with_pora.dart';
import 'package:pora/core/features/predictions_ai/domain/prompt/ai_context.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product.dart';
import 'package:pora/core/features/brief/domain/usecases/get_brief.dart';
import 'package:pora/core/features/predictions_ai/presentation/store/ai_chat_store.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/recipe_creator.dart';
import 'package:pora/core/features/recipe/presentation/widgets/recipe_target_sheet.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_guard.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/chat_message_bubble.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_hero_tags.dart';
import 'package:pora/core/features/insights/presentation/store/statistics_store.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// Модальный чат с PORA. Никакой persist-памяти — история живёт только пока
/// открыт лист. Каждый запрос идёт с system-prompt'ом из `chat_guard`.
///
/// Открывать через `showModalBottomSheet(isScrollControlled: true, ...)` —
/// see `openPoraChatSheet(context)`.
class PoraChatSheet extends StatefulWidget {
  const PoraChatSheet({super.key, required this.heroTag});

  /// Тег Hero-морфа. Приходит от entry-point (CTA/FAB) чтобы избежать
  /// коллизии «Multiple Hero» — оба источника живут в IndexedStack одновременно.
  final Object heroTag;

  @override
  State<PoraChatSheet> createState() => _PoraChatSheetState();
}

class _PoraChatSheetState extends State<PoraChatSheet> {
  late final AiChatStore _store = AiChatStore(
    useCase: GetIt.I<ChatWithPoraUseCase>(),
  );
  final StatisticsStore _statistics = GetIt.I<StatisticsStore>();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<String> _sampleQuestions = const [];
  List<BriefProductEntity> _briefProducts = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sampleQuestions.isNotEmpty) return;
    final l = context.l10n;
    _sampleQuestions =
        [
            l.chatSample1,
            l.chatSample2,
            l.chatSample3,
            l.chatSample4,
            l.chatSample5,
            l.chatSample6,
            l.chatSample7,
            l.chatSample8,
            l.chatSample9,
            l.chatSample10,
            l.chatSample11,
            l.chatSample12,
            l.chatSample13,
            l.chatSample14,
          ]
          ..shuffle(math.Random())
          ..removeRange(4, 10);
    _statistics.loadAll();
    _loadBrief();
  }

  Future<void> _loadBrief() async {
    final brief = await GetIt.I<GetBriefUseCase>().call();
    if (mounted) setState(() => _briefProducts = brief?.products ?? const []);
  }

  @override
  void dispose() {
    _store.reset();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _store.isBusy) return;
    _input.clear();
    final locale = Localizations.localeOf(context).languageCode;
    await _store.send(
      text: text,
      languageCode: locale,
      contextSummary: _shoppingContext,
      context: AiContext(
        allProducts: _statistics.allProducts.toList(),
        briefProducts: _briefProducts,
      ),
    );
    _scrollToBottom();
  }

  String? get _shoppingContext {
    final products = _statistics.popularProducts.take(8).toList();
    if (products.isEmpty) return null;
    final often = products.map((product) => product.name).join(', ');
    final soon = products
        .where((product) => product.currentDay >= 0.8)
        .map((product) => product.name)
        .take(4)
        .join(', ');
    return [
      'Frequently bought: $often.',
      if (soon.isNotEmpty) 'Likely running out soon: $soon.',
    ].join(' ');
  }

  /// Импорт рецепта из assistant-сообщения: показывает target sheet,
  /// dispatch по выбору. Все callsites закрыты `ConnectivityGuard`.
  Future<void> _importRecipe(RecipeEntity recipe) async {
    if (!await ConnectivityGuard.checkWrite(context)) return;
    if (!mounted) return;
    final choice = await showRecipeTargetSheet(
      context,
      recipeTitle: recipe.title,
    );
    if (choice == null || !mounted) return;
    String? outcome;
    switch (choice.kind) {
      case RecipeTargetKind.createShared:
        outcome = await RecipeCreator.createShared(recipe);
        break;
      case RecipeTargetKind.createPersonal:
        outcome = await RecipeCreator.createPersonal(recipe);
        break;
      case RecipeTargetKind.existing:
        final errs = await RecipeCreator.addToExisting(
          recipe,
          choice.existingLid!,
        );
        outcome = errs.isEmpty ? choice.existingLid : null;
        break;
    }
    if (!mounted) return;
    PoraSnackbar.show(
      context,
      message: outcome != null ? context.l10n.done : context.l10n.commonError,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _SheetGrabber(),
              _SheetHeader(heroTag: widget.heroTag),
              Expanded(
                child: Observer(
                  builder: (_) => _store.isEmpty
                      ? _EmptyState(samples: _sampleQuestions)
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.symmetric(
                            horizontal: PoraSpacing.screen,
                            vertical: PoraSpacing.sm,
                          ),
                          itemCount: _store.history.length,
                          itemBuilder: (_, i) {
                            final m = _store.history[i];
                            return ChatMessageBubble(
                              text: m.content,
                              fromUser: m.role == 'user',
                              onImportRecipe: _importRecipe,
                            );
                          },
                        ),
                ),
              ),
              Observer(
                builder: (_) => _store.isBusy
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: _TypingIndicator(),
                      )
                    : const SizedBox.shrink(),
              ),
              Observer(
                builder: (_) => _store.errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PoraSpacing.screen,
                          vertical: 4,
                        ),
                        child: Text(
                          _store.errorMessage!,
                          style: PoraText.small.copyWith(
                            color: PoraColors.danger,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Observer(
                builder: (_) => _ChatInput(
                  controller: _input,
                  busy: _store.isBusy,
                  onSend: _send,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Открывает модалку с чатом. [heroTag] — тег для Hero-морфа
/// (по умолчанию FAB-тег; для CTA передавайте `PoraHeroTags.poraAvatarCta`).
Future<void> openPoraChatSheet(
  BuildContext context, {
  Object heroTag = PoraHeroTags.poraAvatarFab,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PoraChatSheet(heroTag: heroTag),
  );
}

class _SheetGrabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.heroTag});
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        PoraSpacing.screen,
        PoraSpacing.sm,
        PoraSpacing.screen,
        PoraSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsFill.sparkle,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.chatSheetTitle,
                  style: PoraText.itemTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l.chatSheetSubtitle,
                  style: PoraText.small.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.x, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.samples});

  final List<String> samples;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(PoraSpacing.screen),
      children: [
        const SizedBox(height: PoraSpacing.lg),
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PoraColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            PhosphorIconsFill.sparkle,
            size: 30,
            color: PoraColors.primary,
          ),
        ),
        const SizedBox(height: PoraSpacing.md),
        Text(
          l.chatEmptyTitle,
          style: PoraText.itemTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l.chatEmptyExamplesLabel,
          style: PoraText.small.copyWith(color: c.textSubtle),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PoraSpacing.md),
        for (final s in samples)
          _SampleChip(
            text: s,
            onTap: () {
              final state = context
                  .findAncestorStateOfType<_PoraChatSheetState>();
              state?._input.text = s;
              state?._send();
            },
          ),
      ],
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(PoraSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsRegular.magicWand,
                size: 14,
                color: PoraColors.primary,
              ),
              const SizedBox(width: PoraSpacing.sm),
              Expanded(child: Text(text, style: PoraText.small)),
              const Icon(
                PhosphorIconsRegular.arrowRight,
                size: 14,
                color: PoraColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: PoraSpacing.screen, bottom: 4),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              return Row(
                children: List.generate(3, (i) {
                  final p = ((_c.value + i * 0.2) % 1);
                  final s = 0.6 + 0.4 * (1 - (2 * p - 1).abs()).clamp(0, 1);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Transform.scale(
                      scale: s,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: PoraColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: PoraSpacing.sm),
          Text(
            context.l10n.chatTyping,
            style: PoraText.small.copyWith(color: context.colors.textSubtle),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: PoraSpacing.screen,
        right: PoraSpacing.screen,
        top: PoraSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + PoraSpacing.md,
      ),
      // Обычный TextField: цвета/бордер/hint берутся из InputDecorationTheme
      // (app_themes.dart). Send-кнопка вешается как suffixIcon.
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => onSend(),
        style: PoraText.bodyLarge,
        decoration: InputDecoration(
          hintText: context.l10n.chatInputHint,
          filled: true,
          fillColor: context.colors.surfaceAlt,
          prefixIcon: const Icon(
            PhosphorIconsRegular.sparkle,
            size: 18,
            color: PoraColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: PoraColors.primary, width: 1.4),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SendBtn(busy: busy, onTap: onSend),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 40,
          ),
        ),
      ),
    );
  }
}

class _SendBtn extends StatelessWidget {
  const _SendBtn({required this.busy, required this.onTap});
  final bool busy;
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
        decoration: BoxDecoration(
          color: busy
              ? PoraColors.primary.withValues(alpha: 0.5)
              : PoraColors.primary,
          shape: BoxShape.circle,
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                PhosphorIconsBold.paperPlaneTilt,
                color: Colors.white,
                size: 18,
              ),
      ),
    );
  }
}
