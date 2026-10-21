/// Ключи `HiveJsonCache`, которые читаются/пишутся из нескольких мест
/// (сервис, стор, патчер). Значения не менять без bump'а версии — иначе
/// пользователи потеряют offline-снапшоты.
abstract final class CacheKeys {
  static String item(String itemId) => 'items:item:$itemId:v1';

  static const listContentPrefix = 'list-content-v1-';
  static String listContent(String lid) => '$listContentPrefix$lid';

  static String familyLists(String fid) => 'fam-lists-v1-$fid';
}
