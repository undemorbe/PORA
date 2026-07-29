import 'package:flutter/services.dart';

/// Форматтер почты: убирает пробелы и приводит к нижнему регистру.
/// Сохраняет позицию курсора относительно удалённых символов.
class EmailInputFormatter extends TextInputFormatter {
  const EmailInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = format(newValue.text);
    final offset = newValue.selection.end.clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  /// Чистое форматирование строки почты.
  static String format(String raw) =>
      raw.replaceAll(RegExp(r'\s'), '').toLowerCase();
}
