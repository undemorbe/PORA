import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

const _fallback = <Color>[
  PoraColors.primary,
  PoraColors.sage,
  PoraColors.primaryDark,
];

/// Цвет аватара участника: из [MemberEntity.colorCode] (hex), иначе — палитра.
Color memberColor(MemberEntity member, int index) {
  return _parseHex(member.colorCode) ?? _fallback[index % _fallback.length];
}

/// Инициал участника — первая буква имени в верхнем регистре.
String memberInitial(MemberEntity member) =>
    member.name.isEmpty ? '?' : member.name.substring(0, 1).toUpperCase();

Color? _parseHex(String raw) {
  var s = raw.replaceAll('#', '').trim();
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return null;
  final v = int.tryParse(s, radix: 16);
  return v == null ? null : Color(v);
}
