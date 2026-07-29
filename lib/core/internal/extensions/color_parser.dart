import 'package:flutter/material.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

const _fallback = <Color>[
  PoraColors.primary,
  PoraColors.sage,
  PoraColors.primaryDark,
];

/// Цвет аватара участника: из [MemberEntity.colorCode] (hex), иначе — палитра.
Color memberColor(MemberEntity? member, int index) {
  if (member == null) return Colors.black;
  return _parseHex(member.colorCode) ?? _fallback[index % _fallback.length];
}

Color? _parseHex(String raw) {
  var s = raw.replaceAll('#', '').trim();
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return null;
  final v = int.tryParse(s, radix: 16);
  return v == null ? null : Color(v);
}
