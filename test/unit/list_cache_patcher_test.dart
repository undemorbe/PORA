import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/cache/list_cache_patcher.dart';

Map<String, dynamic> _item(String id, {bool checked = false}) => {
  'id': id,
  'name': 'n$id',
  'checked': checked,
};

Map<String, dynamic> _list(String id, List<Map<String, dynamic>> sections) => {
  'id': id,
  'name': 'L$id',
  'sections': sections,
};

Map<String, dynamic> _section(String name, List<Map<String, dynamic>> items) =>
    {'name': name, 'items': items};

Future<List<dynamic>> _items(String lid, {int section = 0}) async {
  final raw = await HiveJsonCache.read(CacheKeys.listContent(lid)) as Map;
  return (raw['sections'] as List)[section]['items'] as List;
}

void main() {
  late Directory tmp;
  const patcher = ListCachePatcher();

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_patcher_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-cache');
    tmp.deleteSync(recursive: true);
  });

  setUp(HiveJsonCache.clear);

  test('patchItem updates the item in every cached list', () async {
    await HiveJsonCache.put(
      CacheKeys.listContent('a'),
      _list('a', [
        _section('s', [_item('i1')]),
      ]),
    );
    await HiveJsonCache.put(
      CacheKeys.listContent('b'),
      _list('b', [
        _section('s', [_item('i2'), _item('i1')]),
      ]),
    );

    await patcher.patchItem('i1', {'checked': true});

    expect((await _items('a')).single['checked'], isTrue);
    final b = await _items('b');
    expect(b[0]['checked'], isFalse); // i2 не тронут
    expect(b[1]['checked'], isTrue);
  });

  test('removeItem drops the item and the emptied section', () async {
    await HiveJsonCache.put(
      CacheKeys.listContent('a'),
      _list('a', [
        _section('s1', [_item('i1')]),
        _section('s2', [_item('i2')]),
      ]),
    );

    await patcher.removeItem('i1');

    final raw = await HiveJsonCache.read(CacheKeys.listContent('a')) as Map;
    final sections = raw['sections'] as List;
    expect(sections, hasLength(1));
    expect(sections.single['name'], 's2');
  });

  test('malformed snapshot is skipped, others still patched', () async {
    await HiveJsonCache.put(CacheKeys.listContent('bad'), 'garbage');
    await HiveJsonCache.put(
      CacheKeys.listContent('a'),
      _list('a', [
        _section('s', [_item('i1')]),
      ]),
    );

    await patcher.patchItem('i1', {'checked': true});

    expect((await _items('a')).single['checked'], isTrue);
    expect(await HiveJsonCache.read(CacheKeys.listContent('bad')), 'garbage');
  });

  test('no match → snapshot is not rewritten', () async {
    await HiveJsonCache.put(
      CacheKeys.listContent('a'),
      _list('a', [
        _section('s', [_item('i1')]),
      ]),
    );
    final before = await HiveJsonCache.readEntry(CacheKeys.listContent('a'));
    await Future<void>.delayed(const Duration(milliseconds: 5));

    await patcher.patchItem('nope', {'checked': true});

    final after = await HiveJsonCache.readEntry(CacheKeys.listContent('a'));
    expect(after!.savedAt, before!.savedAt);
  });
}
