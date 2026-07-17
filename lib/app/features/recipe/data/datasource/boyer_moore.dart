/// Классический Бойер-Мур: bad-character heuristic.
/// Возвращает первый индекс `pattern` в `text` или -1.
///
/// Для коротких паттернов (~20 символов) быстрее наивного из-за
/// пропусков; ассимптотически O(n/m) best-case, O(nm) worst-case.
int boyerMooreIndexOf(String text, String pattern) {
  if (pattern.isEmpty) return 0;
  final n = text.length;
  final m = pattern.length;
  if (m > n) return -1;

  // Bad-character table: последняя позиция символа в pattern.
  final last = <int, int>{};
  for (var i = 0; i < m; i++) {
    last[pattern.codeUnitAt(i)] = i;
  }

  var i = m - 1;
  while (i < n) {
    var j = m - 1;
    var k = i;
    while (j >= 0 && text.codeUnitAt(k) == pattern.codeUnitAt(j)) {
      j--;
      k--;
    }
    if (j < 0) return k + 1;
    final lastPos = last[text.codeUnitAt(i)] ?? -1;
    i += m - (lastPos < j ? lastPos + 1 : j);
  }
  return -1;
}

/// Проверяет содержится ли pattern в text через BM.
bool boyerMooreContains(String text, String pattern) =>
    boyerMooreIndexOf(text, pattern) >= 0;
