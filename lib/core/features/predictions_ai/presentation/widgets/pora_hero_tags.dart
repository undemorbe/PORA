/// Уникальные Hero-теги для sparkle-аватара PORA. У каждого источника —
/// свой тег, sheet принимает нужный через параметр `heroTag`. Причина: в
/// `MainShellRoute` (IndexedStack) обе вкладки остаются в дереве
/// одновременно — единый тег вызывал бы «Multiple Hero» ошибку.
class PoraHeroTags {
  const PoraHeroTags._();

  /// CTA на groups-экране.
  static const poraAvatarCta = 'pora-hero-avatar-cta';

  /// FAB на predictions-экране.
  static const poraAvatarFab = 'pora-hero-avatar-fab';
}
