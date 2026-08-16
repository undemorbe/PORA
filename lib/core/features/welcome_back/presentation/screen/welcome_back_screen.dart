import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/notifications/device_token_sync.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Промежуточный экран для вернувшегося пользователя: «Вспомнили вас!».
/// Показывается после успешного verify-otp (status != notRegistered),
/// затем автоматически уводит на главный экран.
@RoutePage()
class WelcomeBackPage extends StatefulWidget {
  const WelcomeBackPage({super.key});

  @override
  State<WelcomeBackPage> createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.6));
    _c.forward();

    // User only что залогинился — регистрируем устройство на backend.
    syncDeviceToken();

    // Пауза и переход на главный экран.
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      context.router.navigate(const MainShellRoute());
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 108,
                  height: 108,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: PoraColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const PhosphorIcon(
                    PhosphorIconsFill.handWaving,
                    size: 54,
                    color: PoraColors.primary,
                  ), // при желании: smileyWink / heart
                ),
              ),
              const SizedBox(height: PoraSpacing.xl),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(l.welcomeBackTitle, style: PoraText.display),
                    const SizedBox(height: PoraSpacing.sm),
                    Text(
                      l.welcomeBackSubtitle,
                      style: PoraText.subtitle.copyWith(
                        color: context.colors.textSubtle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
