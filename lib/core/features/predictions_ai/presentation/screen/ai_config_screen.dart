import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/predictions_ai/data/config/ai_config.dart';
import 'package:pora/core/features/predictions_ai/data/prefs/ai_config_prefs.dart';
import 'package:pora/core/features/predictions_ai/presentation/widgets/ai_config_fields.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/fade_slide_in.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_rows_card.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';
import 'package:pora/core/internal/widgets/screen_back_header.dart';
import 'package:pora/core/internal/widgets/section_label.dart';

/// Advanced-экран: пользователь задаёт свой ключ OpenRouter и имена моделей
/// для PORA-AI и TIPS. Пустые поля → используются дефолты из .env.
/// Без ключа сменить модели нельзя (поля заблокированы).
@RoutePage()
class AiConfigPage extends StatefulWidget {
  const AiConfigPage({super.key});

  @override
  State<AiConfigPage> createState() => _AiConfigPageState();
}

class _AiConfigPageState extends State<AiConfigPage> {
  final _keyCtrl = TextEditingController();
  final _poraCtrl = TextEditingController();
  final _tipsCtrl = TextEditingController();

  bool _obscureKey = true;
  bool _saving = false;
  bool _loaded = false;

  AiConfigPrefs get _prefs => GetIt.I<AiConfigPrefs>();
  AiConfig get _config => GetIt.I<AiConfig>();

  bool get _hasKey => _keyCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _keyCtrl.addListener(_onKeyChanged);
    _load();
  }

  @override
  void dispose() {
    _keyCtrl.removeListener(_onKeyChanged);
    _keyCtrl.dispose();
    _poraCtrl.dispose();
    _tipsCtrl.dispose();
    super.dispose();
  }

  void _onKeyChanged() => setState(() {});

  Future<void> _load() async {
    final key = await _prefs.apiKey();
    final pora = await _prefs.poraModel();
    final tips = await _prefs.tipsModel();
    if (!mounted) return;
    _keyCtrl.text = key ?? '';
    _poraCtrl.text = pora ?? '';
    _tipsCtrl.text = tips ?? '';
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _prefs.save(
      apiKey: _keyCtrl.text,
      // Без ключа кастомные модели не сохраняем — дефолты из .env.
      poraModel: _hasKey ? _poraCtrl.text : '',
      tipsModel: _hasKey ? _tipsCtrl.text : '',
    );
    await _config.reload();
    unawaited(AnalyticsService.instance.logAiConfigSaved(custom: _hasKey));
    if (!mounted) return;
    setState(() => _saving = false);
    PoraSnackbar.show(context, message: context.l10n.aiConfigSaved);
  }

  Future<void> _reset() async {
    setState(() => _saving = true);
    await _prefs.reset();
    await _config.reload();
    if (!mounted) return;
    _keyCtrl.clear();
    _poraCtrl.clear();
    _tipsCtrl.clear();
    setState(() => _saving = false);
    PoraSnackbar.show(context, message: context.l10n.aiConfigResetDone);
  }

  void _showInfo() {
    final l = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        shape: const RoundedRectangleBorder(borderRadius: PoraRadii.card),
        title: Row(
          children: [
            const Icon(PhosphorIconsFill.info, color: PoraColors.primary),
            const SizedBox(width: PoraSpacing.sm),
            Expanded(
              child: Text(l.aiConfigInfoTitle, style: PoraText.navTitle),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            l.aiConfigInfoBody,
            style: PoraText.body.copyWith(color: ctx.colors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.aiConfigInfoClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            PoraSpacing.sm,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            FadeSlideIn(
              delay: const Duration(milliseconds: 40),
              child: ScreenBackHeader(
                title: l.aiConfigTitle,
                trailing: IconButton(
                  icon: const Icon(PhosphorIconsRegular.info),
                  tooltip: l.aiConfigInfoTitle,
                  onPressed: _showInfo,
                ),
              ),
            ),
            const SizedBox(height: PoraSpacing.sm),
            FadeSlideIn(
              delay: const Duration(milliseconds: 90),
              child: Text(
                l.aiConfigIntro,
                style: PoraText.small.copyWith(color: context.colors.textMuted),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),

            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: SectionLabel(l.aiConfigApiKeyLabel),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 180),
              child: AiConfigFieldCard(
                icon: PhosphorIconsRegular.key,
                controller: _keyCtrl,
                hint: l.aiConfigApiKeyHint,
                obscure: _obscureKey,
                enabled: _loaded && !_saving,
                trailing: IconButton(
                  icon: Icon(
                    _obscureKey
                        ? PhosphorIconsRegular.eye
                        : PhosphorIconsRegular.eyeSlash,
                  ),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),

            FadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: SectionLabel(l.aiConfigModelsSection),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: Opacity(
                opacity: _hasKey ? 1 : 0.5,
                child: PoraRowsCard(
                  children: [
                    AiConfigFieldTile(
                      icon: PhosphorIconsFill.sparkle,
                      label: l.aiConfigPoraModelLabel,
                      controller: _poraCtrl,
                      hint: l.aiConfigPoraModelHint,
                      enabled: _loaded && _hasKey && !_saving,
                    ),
                    AiConfigFieldTile(
                      icon: PhosphorIconsRegular.lightbulb,
                      label: l.aiConfigTipsModelLabel,
                      controller: _tipsCtrl,
                      hint: l.aiConfigTipsModelHint,
                      enabled: _loaded && _hasKey && !_saving,
                    ),
                  ],
                ),
              ),
            ),
            if (!_hasKey) ...[
              const SizedBox(height: PoraSpacing.sm),
              Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.lockSimple,
                    size: 16,
                    color: PoraColors.primary,
                  ),
                  const SizedBox(width: PoraSpacing.xs),
                  Expanded(
                    child: Text(
                      l.aiConfigNeedKeyNote,
                      style: PoraText.small.copyWith(color: PoraColors.primary),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: PoraSpacing.xl),

            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: PoraPrimaryButton(
                label: l.save,
                icon: PhosphorIconsRegular.check,
                isLoading: _saving,
                onPressed: _loaded && !_saving ? _save : null,
              ),
            ),
            const SizedBox(height: PoraSpacing.sm),
            FadeSlideIn(
              delay: const Duration(milliseconds: 340),
              child: PoraOutlineButton(
                label: l.aiConfigReset,
                onPressed: _loaded && !_saving ? _reset : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
