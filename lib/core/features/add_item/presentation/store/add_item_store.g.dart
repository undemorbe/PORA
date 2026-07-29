// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_item_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AddItemStore on _AddItemStoreBase, Store {
  Computed<bool>? _$hasCustomUnitComputed;

  @override
  bool get hasCustomUnit => (_$hasCustomUnitComputed ??= Computed<bool>(
    () => super.hasCustomUnit,
    name: '_AddItemStoreBase.hasCustomUnit',
  )).value;
  Computed<bool>? _$hasCustomSectionComputed;

  @override
  bool get hasCustomSection => (_$hasCustomSectionComputed ??= Computed<bool>(
    () => super.hasCustomSection,
    name: '_AddItemStoreBase.hasCustomSection',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: '_AddItemStoreBase.canSubmit',
  )).value;

  late final _$nameAtom = Atom(
    name: '_AddItemStoreBase.name',
    context: context,
  );

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$quantityAtom = Atom(
    name: '_AddItemStoreBase.quantity',
    context: context,
  );

  @override
  int get quantity {
    _$quantityAtom.reportRead();
    return super.quantity;
  }

  @override
  set quantity(int value) {
    _$quantityAtom.reportWrite(value, super.quantity, () {
      super.quantity = value;
    });
  }

  late final _$unitAtom = Atom(
    name: '_AddItemStoreBase.unit',
    context: context,
  );

  @override
  String get unit {
    _$unitAtom.reportRead();
    return super.unit;
  }

  @override
  set unit(String value) {
    _$unitAtom.reportWrite(value, super.unit, () {
      super.unit = value;
    });
  }

  late final _$sectionAtom = Atom(
    name: '_AddItemStoreBase.section',
    context: context,
  );

  @override
  String get section {
    _$sectionAtom.reportRead();
    return super.section;
  }

  @override
  set section(String value) {
    _$sectionAtom.reportWrite(value, super.section, () {
      super.section = value;
    });
  }

  late final _$priorityAtom = Atom(
    name: '_AddItemStoreBase.priority',
    context: context,
  );

  @override
  int get priority {
    _$priorityAtom.reportRead();
    return super.priority;
  }

  @override
  set priority(int value) {
    _$priorityAtom.reportWrite(value, super.priority, () {
      super.priority = value;
    });
  }

  late final _$urgentAtom = Atom(
    name: '_AddItemStoreBase.urgent',
    context: context,
  );

  @override
  bool get urgent {
    _$urgentAtom.reportRead();
    return super.urgent;
  }

  @override
  set urgent(bool value) {
    _$urgentAtom.reportWrite(value, super.urgent, () {
      super.urgent = value;
    });
  }

  late final _$remindAtom = Atom(
    name: '_AddItemStoreBase.remind',
    context: context,
  );

  @override
  bool get remind {
    _$remindAtom.reportRead();
    return super.remind;
  }

  @override
  set remind(bool value) {
    _$remindAtom.reportWrite(value, super.remind, () {
      super.remind = value;
    });
  }

  late final _$remindDaysAtom = Atom(
    name: '_AddItemStoreBase.remindDays',
    context: context,
  );

  @override
  int get remindDays {
    _$remindDaysAtom.reportRead();
    return super.remindDays;
  }

  @override
  set remindDays(int value) {
    _$remindDaysAtom.reportWrite(value, super.remindDays, () {
      super.remindDays = value;
    });
  }

  late final _$busyAtom = Atom(
    name: '_AddItemStoreBase.busy',
    context: context,
  );

  @override
  bool get busy {
    _$busyAtom.reportRead();
    return super.busy;
  }

  @override
  set busy(bool value) {
    _$busyAtom.reportWrite(value, super.busy, () {
      super.busy = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_AddItemStoreBase.errorMessage',
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

  late final _$submitAsyncAction = AsyncAction(
    '_AddItemStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit() {
    return _$submitAsyncAction.run(() => super.submit());
  }

  late final _$_AddItemStoreBaseActionController = ActionController(
    name: '_AddItemStoreBase',
    context: context,
  );

  @override
  void setName(String v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.setName',
    );
    try {
      return super.setName(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUnit(String v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.setUnit',
    );
    try {
      return super.setUnit(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSection(String v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.setSection',
    );
    try {
      return super.setSection(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPriority(int v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.setPriority',
    );
    try {
      return super.setPriority(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleUrgent(bool v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.toggleUrgent',
    );
    try {
      return super.toggleUrgent(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleRemind(bool v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.toggleRemind',
    );
    try {
      return super.toggleRemind(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRemindDays(int v) {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.setRemindDays',
    );
    try {
      return super.setRemindDays(v);
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void increment() {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.increment',
    );
    try {
      return super.increment();
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo = _$_AddItemStoreBaseActionController.startAction(
      name: '_AddItemStoreBase.decrement',
    );
    try {
      return super.decrement();
    } finally {
      _$_AddItemStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
quantity: ${quantity},
unit: ${unit},
section: ${section},
priority: ${priority},
urgent: ${urgent},
remind: ${remind},
remindDays: ${remindDays},
busy: ${busy},
errorMessage: ${errorMessage},
hasCustomUnit: ${hasCustomUnit},
hasCustomSection: ${hasCustomSection},
canSubmit: ${canSubmit}
    ''';
  }
}
