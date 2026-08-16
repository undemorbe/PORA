import 'package:flutter/material.dart';

/// Тумблер Pora. Внешний вид задаётся `switchTheme` в PoraTheme.
class PoraToggle extends StatelessWidget {
  const PoraToggle({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(value: value, onChanged: onChanged);
  }
}
