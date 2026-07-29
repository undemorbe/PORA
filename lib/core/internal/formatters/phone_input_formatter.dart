import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static String format(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return '';
    if (d.startsWith('8')) d = '7${d.substring(1)}';
    if (!d.startsWith('7')) d = '7$d';
    if (d.length > 11) d = d.substring(0, 11);

    final rest = d.substring(1);
    final b = StringBuffer('+7');
    void chunk(int start, int end, String sep) {
      if (rest.length > start) {
        b.write(sep);
        b.write(rest.substring(start, rest.length < end ? rest.length : end));
      }
    }

    chunk(0, 3, ' ');
    chunk(3, 6, ' ');
    chunk(6, 8, '-');
    chunk(8, 10, '-');
    return b.toString();
  }
}
