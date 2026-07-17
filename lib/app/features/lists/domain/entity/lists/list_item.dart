/// Товар в общем списке. Цвет участника определяется в UI-слое по [addedBy].
class ListItem {
  const ListItem({
    required this.name,
    required this.addedBy,
    this.qty,
    this.urgent = false,
    this.checked = false,
  });

  final String name;
  final String? qty;
  final String addedBy; // инициал участника, напр. «Б» / «А»
  final bool urgent;
  final bool checked;
}

/// Секция списка (отдел магазина) с товарами.
class ListSection {
  const ListSection({required this.title, required this.items});

  final String title;
  final List<ListItem> items;
}
