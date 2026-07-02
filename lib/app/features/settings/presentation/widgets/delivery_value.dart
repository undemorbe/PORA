import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';

/// Трейлинг строки «Доставка»: название сервиса + шеврон.
class DeliveryValue extends StatelessWidget {
  const DeliveryValue({super.key, this.value = 'Самокат'});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: PoraText.small),
        const SizedBox(width: PoraSpacing.sm),
        PoraSettingRow.chevron,
      ],
    );
  }
}
