import 'package:equatable/equatable.dart';

/// Тема для «Совета дня». Predefined приходят с зашитыми l10n-ключами,
/// custom — с сырым текстом введённым пользователем.
class TipTopic extends Equatable {
  const TipTopic({
    required this.id,
    required this.isCustom,
    this.l10nKey,
    this.rawText,
  }) : assert(
          (isCustom && rawText != null) || (!isCustom && l10nKey != null),
          'custom → rawText; predefined → l10nKey',
        );

  /// Стабильный идентификатор — для (де)активации/удаления.
  /// Predefined: тот же что `l10nKey` (например `tipTopicHerbs`).
  /// Custom: `custom-<sanitized-text>`.
  final String id;
  final bool isCustom;
  final String? l10nKey;
  final String? rawText;

  factory TipTopic.predefined(String l10nKey) => TipTopic(
        id: l10nKey,
        isCustom: false,
        l10nKey: l10nKey,
      );

  factory TipTopic.custom(String text) {
    final trimmed = text.trim();
    return TipTopic(
      id: 'custom-${trimmed.toLowerCase()}',
      isCustom: true,
      rawText: trimmed,
    );
  }

  @override
  List<Object?> get props => [id];
}
