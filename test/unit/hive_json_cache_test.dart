import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    tmp = Directory.systemTemp.createTempSync('pora_cache_test');
    Hive.init(tmp.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('pora-cache');
    tmp.deleteSync(recursive: true);
  });

  setUp(HiveJsonCache.clear);

  test('keysWithPrefix returns only matching keys', () async {
    await HiveJsonCache.put(CacheKeys.listContent('a'), {'id': 'a'});
    await HiveJsonCache.put(CacheKeys.listContent('b'), {'id': 'b'});
    await HiveJsonCache.put(CacheKeys.item('i1'), {'id': 'i1'});

    final keys = await HiveJsonCache.keysWithPrefix(
      CacheKeys.listContentPrefix,
    );
    expect(keys.toSet(), {
      CacheKeys.listContent('a'),
      CacheKeys.listContent('b'),
    });
  });

  test('CacheKeys keep legacy values (existing snapshots stay valid)', () {
    expect(CacheKeys.item('x'), 'items:item:x:v1');
    expect(CacheKeys.listContent('x'), 'list-content-v1-x');
    expect(CacheKeys.familyLists('x'), 'fam-lists-v1-x');
  });
}
