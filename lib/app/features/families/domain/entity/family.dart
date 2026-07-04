/// Семья (домохозяйство) пользователя. Цвета аватаров резолвятся в UI.
class Family {
  const Family({
    required this.id,
    required this.name,
    required this.memberInitials,
    this.itemCount = 0,
    this.isCurrent = false,
  });

  final String id;
  final String name;
  final List<String> memberInitials;
  final int itemCount;

  /// Активная (выбранная) семья.
  final bool isCurrent;
}
