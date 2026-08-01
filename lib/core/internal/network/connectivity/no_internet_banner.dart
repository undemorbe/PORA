import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_store.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Оборачивает [child] баннером «нет интернета» который выезжает сверху.
/// `onRetry` — обычно вызывает `refresh` текущей страницы.
class NoInternetWrapper extends StatelessWidget {
  const NoInternetWrapper({super.key, required this.child, this.onRetry});

  final Widget child;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<ConnectivityStore>();
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * 0.08,
          child: Observer(
            builder: (context) {
              return AnimatedSlide(
                offset: store.online ? const Offset(0, -1) : Offset.zero,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: store.online ? 0 : 1,
                  duration: const Duration(milliseconds: 260),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PoraSpacing.md,
                        PoraSpacing.sm,
                        PoraSpacing.md,
                        0,
                      ),
                      child: _Banner(
                        onRetry: () async {
                          await store.recheck();
                          if (store.online && onRetry != null) await onRetry!();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoraColors.danger,
      borderRadius: PoraRadii.md,
      elevation: 3,
      child: InkWell(
        onTap: onRetry,
        borderRadius: PoraRadii.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PoraSpacing.md,
            vertical: PoraSpacing.sm + 2,
          ),
          child: Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsFill.wifiSlash,
                size: 18,
                color: PoraColors.inkInverse,
              ),
              const SizedBox(width: PoraSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.noInternet,
                  style: PoraText.body.copyWith(
                    color: PoraColors.inkInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoraSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: PoraColors.inkInverse.withValues(alpha: 0.18),
                  borderRadius: PoraRadii.sm,
                ),
                child: Text(
                  context.l10n.retry,
                  style: PoraText.small.copyWith(
                    color: PoraColors.inkInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
