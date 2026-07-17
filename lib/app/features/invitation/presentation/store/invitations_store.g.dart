// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitations_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$InvitationsStore on _InvitationsStoreBase, Store {
  late final _$isLoadingAtom = Atom(
    name: '_InvitationsStoreBase.isLoading',
    context: context,
  );

  @override
  bool? get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool? value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isSuccessAtom = Atom(
    name: '_InvitationsStoreBase.isSuccess',
    context: context,
  );

  @override
  bool? get isSuccess {
    _$isSuccessAtom.reportRead();
    return super.isSuccess;
  }

  @override
  set isSuccess(bool? value) {
    _$isSuccessAtom.reportWrite(value, super.isSuccess, () {
      super.isSuccess = value;
    });
  }

  late final _$linkCodeAtom = Atom(
    name: '_InvitationsStoreBase.linkCode',
    context: context,
  );

  @override
  String? get linkCode {
    _$linkCodeAtom.reportRead();
    return super.linkCode;
  }

  @override
  set linkCode(String? value) {
    _$linkCodeAtom.reportWrite(value, super.linkCode, () {
      super.linkCode = value;
    });
  }

  late final _$linkUrlAtom = Atom(
    name: '_InvitationsStoreBase.linkUrl',
    context: context,
  );

  @override
  String? get linkUrl {
    _$linkUrlAtom.reportRead();
    return super.linkUrl;
  }

  @override
  set linkUrl(String? value) {
    _$linkUrlAtom.reportWrite(value, super.linkUrl, () {
      super.linkUrl = value;
    });
  }

  late final _$copyToClipboardAsyncAction = AsyncAction(
    '_InvitationsStoreBase.copyToClipboard',
    context: context,
  );

  @override
  Future<void> copyToClipboard(String textToCopy) {
    return _$copyToClipboardAsyncAction.run(
      () => super.copyToClipboard(textToCopy),
    );
  }

  late final _$connectToFamilyAsyncAction = AsyncAction(
    '_InvitationsStoreBase.connectToFamily',
    context: context,
  );

  @override
  Future<void> connectToFamily({required String code}) {
    return _$connectToFamilyAsyncAction.run(
      () => super.connectToFamily(code: code),
    );
  }

  late final _$generateLinkCodeAsyncAction = AsyncAction(
    '_InvitationsStoreBase.generateLinkCode',
    context: context,
  );

  @override
  Future<void> generateLinkCode({required String familyId}) {
    return _$generateLinkCodeAsyncAction.run(
      () => super.generateLinkCode(familyId: familyId),
    );
  }

  late final _$shareLinkCodeAsyncAction = AsyncAction(
    '_InvitationsStoreBase.shareLinkCode',
    context: context,
  );

  @override
  Future<void> shareLinkCode({required String linkCode}) {
    return _$shareLinkCodeAsyncAction.run(
      () => super.shareLinkCode(linkCode: linkCode),
    );
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isSuccess: ${isSuccess},
linkCode: ${linkCode},
linkUrl: ${linkUrl}
    ''';
  }
}
