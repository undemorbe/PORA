import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
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
import 'package:pora/core/features/predictions_ai/presentation/widgets/pora_chat_widgets.dart';

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
              ChatSheetGrabber(),
              ChatSheetHeader(heroTag: widget.heroTag),
              Expanded(
                child: Observer(
                  builder: (_) => _store.isEmpty
                      ? ChatEmptyState(
                          samples: _sampleQuestions,
                          onSampleTap: (s) {
                            _input.text = s;
                            _send();
                          },
                        )
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
                        child: ChatTypingIndicator(),
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
                builder: (_) => ChatInputBar(
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
