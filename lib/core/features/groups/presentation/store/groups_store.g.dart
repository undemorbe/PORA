// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GroupsStore on _GroupsStoreBase, Store {
  late final _$groupsAtom = Atom(
    name: '_GroupsStoreBase.groups',
    context: context,
  );

  @override
  ObservableList<GroupEntity> get groups {
    _$groupsAtom.reportRead();
    return super.groups;
  }

  @override
  set groups(ObservableList<GroupEntity> value) {
    _$groupsAtom.reportWrite(value, super.groups, () {
      super.groups = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_GroupsStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_GroupsStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    '_GroupsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$createGroupAsyncAction = AsyncAction(
    '_GroupsStoreBase.createGroup',
    context: context,
  );

  @override
  Future<bool> createGroup({required String name, required bool shared}) {
    return _$createGroupAsyncAction.run(
      () => super.createGroup(name: name, shared: shared),
    );
  }

  late final _$deleteGroupAsyncAction = AsyncAction(
    '_GroupsStoreBase.deleteGroup',
    context: context,
  );

  @override
  Future<void> deleteGroup(GroupEntity g) {
    return _$deleteGroupAsyncAction.run(() => super.deleteGroup(g));
  }

  @override
  String toString() {
    return '''
groups: ${groups},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
