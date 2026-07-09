import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/splash/presentation/store/splash_store.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Splash: тележка въезжает слева, буквы «Pora» всплывают по одной,
/// после анимации — переход на онбординг.
@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _cartSlide;
  late final Animation<double> _cartFade;
  late final Animation<double> _tagline;

  //! Add locale
  static const _letters = ['P', 'o', 'r', 'a'];

  @override
  void initState() {
    super.initState();

    SplashStore controller = SplashStore();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _cartSlide = Tween<Offset>(begin: const Offset(-1.8, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _c,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
          ),
        );
    _cartFade = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.28));
    _tagline = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.82, 1.0, curve: Curves.easeOut),
    );

    _c.forward().whenComplete(() {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 450), () async {
        final routeDestination = await controller.whereToRoute();

        if (!mounted) return;

        context.router.replace(routeDestination);
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Одна буква со staggered-появлением (fade + подъём снизу).
  Widget _letter(String ch, int i) {
    final start = 0.45 + i * 0.09;
    final anim = CurvedAnimation(
      parent: _c,
      curve: Interval(
        start,
        (start + 0.28).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 14),
          child: child,
        ),
      ),
      child: Text(
        ch,
        style: const TextStyle(
          fontFamily: kPoraFontFamily,
          fontSize: 46,
          fontWeight: FontWeight.w800,
          color: PoraColors.primary,
          height: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoraColors.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _cartFade,
                  child: SlideTransition(
                    position: _cartSlide,
                    child: const PhosphorIcon(
                      PhosphorIconsFill.shoppingCart,
                      size: 64,
                      color: PoraColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                for (var i = 0; i < _letters.length; i++)
                  _letter(_letters[i], i),
              ],
            ),
            const SizedBox(height: 18),
            FadeTransition(
              opacity: _tagline,
              child: Text(
                context.l10n.splashTagline,
                style: PoraText.subtitle.copyWith(color: PoraColors.textSubtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
