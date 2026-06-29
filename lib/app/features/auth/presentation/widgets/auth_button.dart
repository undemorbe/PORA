import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.text, required this.onPressed, required this.backgroundColor});
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      onTap: onPressed,
      tileColor: backgroundColor,
    );
  }
}