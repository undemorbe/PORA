import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/splash/presentation/store/splash_store.dart';
import 'package:pora/app/internal/bootstrap/app_bootstrap.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Splash: тележка въезжает слева → буквы «Pora» появляются → продукты
/// падают с bounce в тележку → тележка уезжает вправо → навигация.
@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Cart.
  late final Animation<Offset> _cartIn;
  late final Animation<Offset> _cartOut;
  late final Animation<double> _cartFade;

  // Letters.
  late final Animation<double> _lettersFade;

  // Tagline.
  late final Animation<double> _tagline;

  // Drops (продукты падают в тележку).
  late final List<Animation<double>> _drops;
  late final List<Animation<double>> _dropFades;

  static const _letters = ['P', 'o', 'r', 'a'];
  static const List<String> _items = ['🥛', '🍞', '🥑'];

  static const double _cartSize = 64;
  static const double _itemSize = 26;
  static const double _dropStartY = -90;
  static const double _dropEndY = -12;

  @override
  void initState() {
    super.initState();

    final SplashStore controller = SplashStore();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // 0 → 0.22: cart in (easeOutBack — лёгкий отскок).
    _cartIn = Tween<Offset>(
      begin: const Offset(-1.8, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOutBack),
      ),
    );

    _cartFade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.15),
    );

    _lettersFade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.18, 0.40, curve: Curves.easeOut),
    );

    // Drops: staggered, bounceOut в конце — «шлёпается» в корзину.
    _drops = List.generate(_items.length, (i) {
      final start = 0.42 + i * 0.10;
      return CurvedAnimation(
        parent: _c,
        curve: Interval(
          start,
          (start + 0.18).clamp(0.0, 1.0),
          curve: Curves.bounceOut,
        ),
      );
    });

    _dropFades = List.generate(_items.length, (i) {
      final start = 0.40 + i * 0.10;
      return CurvedAnimation(
        parent: _c,
        curve: Interval(
          start,
          (start + 0.10).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      );
    });

    _tagline = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.55, 0.78, curve: Curves.easeOut),
    );

    // 0.82 → 1.0: cart out (easeInBack — разгон с оттяжкой).
    _cartOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.4, 0),
    ).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.82, 1.0, curve: Curves.easeInBack),
      ),
    );

    _navigateWhenReady(controller);
  }

  Future<void> _navigateWhenReady(SplashStore controller) async {
    // Ждём и анимацию, и bootstrap — то, что дольше, определяет длительность.
    await Future.wait([
      _c.forward().orCancel.catchError((_) {}),
      AppBootstrap.instance.ready,
    ]);
    if (!mounted) return;
    final routeDestination = await controller.whereToRoute();
    if (!mounted) return;
    context.router.replace(routeDestination);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _letter(String ch, int i) {
    final start = 0.20 + i * 0.05;
    final anim = CurvedAnimation(
      parent: _c,
      curve: Interval(
        start,
        (start + 0.20).clamp(0.0, 1.0),
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

  Widget _drop(int i) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final progress = _drops[i].value;
        final fade = _dropFades[i].value;
        final y = _dropStartY + (_dropEndY - _dropStartY) * progress;
        final rot = (1 - progress) * 0.6 * (i.isEven ? -1 : 1);
        // i=0,1 внутри чаши; i=2 (авокадо) наполовину торчит справа.
        const lefts = <double>[8, 22, 32];
        return Positioned(
          left: lefts[i],
          top: _cartSize / 2 + y,
          child: Opacity(
            opacity: fade,
            child: Transform.rotate(angle: rot, child: child),
          ),
        );
      },
      child: Text(
        _items[i],
        style: const TextStyle(fontSize: _itemSize),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoraColors.cream,
      body: Center(
        child: Transform.translate(
          offset: const Offset(-24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            SlideTransition(
              position: _cartOut,
              child: SlideTransition(
                position: _cartIn,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cart + падающие продукты в общем Stack.
                    SizedBox(
                      width: _cartSize + 18,
                      height: _cartSize + 20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Продукты — ниже слоем. Тележка их перекрывает,
                          // создавая эффект «упало внутрь».
                          for (var i = 0; i < _items.length; i++) _drop(i),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: FadeTransition(
                              opacity: _cartFade,
                              child: const PhosphorIcon(
                                PhosphorIconsFill.shoppingCart,
                                size: _cartSize,
                                color: PoraColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    FadeTransition(
                      opacity: _lettersFade,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < _letters.length; i++)
                            _letter(_letters[i], i),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
    ),
    );
  }
}
