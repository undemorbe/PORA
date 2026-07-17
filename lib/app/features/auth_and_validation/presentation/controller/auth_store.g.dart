// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStoreBase, Store {
  late final _$successAtom = Atom(
    name: '_AuthStoreBase.success',
    context: context,
  );

  @override
  bool? get success {
    _$successAtom.reportRead();
    return super.success;
  }

  @override
  set success(bool? value) {
    _$successAtom.reportWrite(value, super.success, () {
      super.success = value;
    });
  }

  late final _$scaffoldMessageAtom = Atom(
    name: '_AuthStoreBase.scaffoldMessage',
    context: context,
  );

  @override
  String? get scaffoldMessage {
    _$scaffoldMessageAtom.reportRead();
    return super.scaffoldMessage;
  }

  @override
  set scaffoldMessage(String? value) {
    _$scaffoldMessageAtom.reportWrite(value, super.scaffoldMessage, () {
      super.scaffoldMessage = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_AuthStoreBase.isLoading',
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

  late final _$statusAtom = Atom(
    name: '_AuthStoreBase.status',
    context: context,
  );

  @override
  String? get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(String? value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$sendOtpAsyncAction = AsyncAction(
    '_AuthStoreBase.sendOtp',
    context: context,
  );

  @override
  Future<void> sendOtp({required String destination}) {
    return _$sendOtpAsyncAction.run(
      () => super.sendOtp(destination: destination),
    );
  }

  late final _$verifyOtpAsyncAction = AsyncAction(
    '_AuthStoreBase.verifyOtp',
    context: context,
  );

  @override
  Future<void> verifyOtp({required String destination, required String code}) {
    return _$verifyOtpAsyncAction.run(
      () => super.verifyOtp(destination: destination, code: code),
    );
  }

  @override
  String toString() {
    return '''
success: ${success},
scaffoldMessage: ${scaffoldMessage},
isLoading: ${isLoading},
status: ${status}
    ''';
  }
}
