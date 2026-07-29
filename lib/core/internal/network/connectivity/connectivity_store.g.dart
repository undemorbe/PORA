// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ConnectivityStore on _ConnectivityStoreBase, Store {
  late final _$onlineAtom = Atom(
    name: '_ConnectivityStoreBase.online',
    context: context,
  );

  @override
  bool get online {
    _$onlineAtom.reportRead();
    return super.online;
  }

  @override
  set online(bool value) {
    _$onlineAtom.reportWrite(value, super.online, () {
      super.online = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    '_ConnectivityStoreBase.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$_ConnectivityStoreBaseActionController = ActionController(
    name: '_ConnectivityStoreBase',
    context: context,
  );

  @override
  void _apply(List<ConnectivityResult> results) {
    final _$actionInfo = _$_ConnectivityStoreBaseActionController.startAction(
      name: '_ConnectivityStoreBase._apply',
    );
    try {
      return super._apply(results);
    } finally {
      _$_ConnectivityStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
online: ${online}
    ''';
  }
}
