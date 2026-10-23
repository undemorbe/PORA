/// Дефолтные значения для селекторов при создании продукта.
/// Backend не имеет фиксированного enum'а — принимает произвольные строки.
///
/// Строки units/sections — канонические значения, которые уходят на backend
/// и лежат в БД/кэше (исторически русские). Для показа их переводит
/// `ItemLabelsX` (`presentation/item_labels.dart`), сами значения не меняем —
/// иначе старые товары разъедутся по разным секциям.
class AddItemDefaults {
  const AddItemDefaults._();

  static const List<String> units = ['шт', 'г', 'кг', 'мл', 'л', 'уп'];

  /// (emoji, name). Name уходит на backend, emoji — только UI.
  static const List<(String, String)> sections = [
    ('🥦', 'Овощи и фрукты'),
    ('🥛', 'Молочное'),
    ('🍝', 'Бакалея'),
    ('🧃', 'Напитки'),
    ('🍞', 'Хлеб'),
    ('🧀', 'Разное'),
  ];

  static const String defaultUnit = 'шт';
  static const String defaultSection = 'Разное';

  /// Секция, под которой backend группирует товары без секции
  /// (`entities.OthersSectionName`). Приходит только с сервера.
  static const String othersSection = 'Прочее';

  //! Priority: backend хранит int 1..3 (`HighestItemPriority = 3`).
  static const int priorityLow = 1;
  static const int priorityMed = 2;
  static const int priorityHigh = 3;
  static const List<int> priorities = [priorityLow, priorityMed, priorityHigh];

  static const int remindDaysMin = 1;
  static const int remindDaysMax = 7;
}
