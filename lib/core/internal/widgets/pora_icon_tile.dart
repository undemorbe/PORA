import 'package:flutter/material.dart';

/// Скруглённая плитка с эмодзи/иконкой (превью рецепта, карточка товара, поиск).
class PoraIconTile extends StatelessWidget {
  const PoraIconTile({
    super.key,
    required this.color,
    required this.child,
    this.size = 46,
    this.borderRadius,
    this.circle = false,
  });

  final Color color;
  final Widget child;
  final double size;
  final BorderRadius? borderRadius;
  final bool circle;

  /// Удобный конструктор для эмодзи-плитки.
  factory PoraIconTile.emoji(
    String emoji, {
    Key? key,
    required Color color,
    double size = 46,
    double emojiSize = 22,
    BorderRadius? borderRadius,
    bool circle = false,
  }) {
    return PoraIconTile(
      key: key,
      color: color,
      size: size,
      borderRadius: borderRadius,
      circle: circle,
      child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle
            ? null
            : (borderRadius ?? BorderRadius.circular(14)),
      ),
      child: child,
    );
  }
}
