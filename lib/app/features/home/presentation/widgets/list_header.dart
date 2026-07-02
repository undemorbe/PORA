import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';

/// Шапка списка: заголовок + подпись + перекрывающиеся аватары участников.
class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.members,
  });

  final String title;
  final String subtitle;

  /// Участники: (инициал, цвет). Аватары накладываются друг на друга.
  final List<(String, Color)> members;

  static const double _avatar = 34;
  static const double _overlap = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: PoraText.title),
              const SizedBox(height: 6),
              Text(subtitle, style: PoraText.caption),
            ],
          ),
        ),
        SizedBox(
          height: _avatar,
          width: _avatar + (members.length - 1) * _overlap,
          child: Stack(
            children: [
              for (var i = 0; i < members.length; i++)
                Positioned(
                  left: i * _overlap,
                  child: PoraAvatar(
                    initial: members[i].$1,
                    color: members[i].$2,
                    size: _avatar,
                    ring: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
