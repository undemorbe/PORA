import 'package:flutter/material.dart';

/// Устраняет boilerplate `AnimationController` в каждом step'е.
/// Заводит контроллер с `.repeat()`, даёт билдеру нормализованный t в [0..1].
///
/// Пример:
/// ```dart
/// TutorialTicker(
///   duration: const Duration(milliseconds: 2200),
///   builder: (context, t) => Stack(...),
/// )
/// ```
class TutorialTicker extends StatefulWidget {
  const TutorialTicker({
    super.key,
    required this.duration,
    required this.builder,
  });

  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<TutorialTicker> createState() => _TutorialTickerState();
}

class _TutorialTickerState extends State<TutorialTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, _c.value),
    );
  }
}
