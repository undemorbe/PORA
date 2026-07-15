import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(hintText: 'Phone'));
  }
}
